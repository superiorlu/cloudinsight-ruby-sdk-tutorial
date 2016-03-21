#! /usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'oneapm_ci'
require 'redis'
require_relative 'time_formater'

TRANS_MAP = {}.tap do |h|
  h['社区会员'] = :members
  h['帖子数'] = :posts
  h['回帖数'] = :replies
end

topic_page = Nokogiri::HTML(open('https://ruby-china.org/topics'))

statc_info = topic_page.css('div.panel.panel-default').select do |sidebar|
  sidebar.css('div.panel-heading').text == '统计信息'
end.first

statc_hash = {}
statc_info.css('li.list-group-item').each do |info|
  match_info = /(?<name>.*):\s+(?<num>.*)\s+(.*)/.match(info.text)
  statc_hash[TRANS_MAP[match_info[:name]]] = match_info[:num]
end

statsd = OneapmCi::Statsd.new
redis = Redis.new

statc_hash.each do |name, num|
  origin_num = redis.get("ruby_china.#{name}")
  up = origin_num.nil? ? 0 : num.to_i - origin_num.to_i
  puts "#{TimeFormater.now} name:#{name} num:#{num} up:#{up}"
  statsd.gauge("ruby_china_#{name}.up", up, ['ruby_china.oneapm'])
  statsd.gauge("ruby_china.#{name}", num, ['ruby_china.oneapm'])
  redis.set("ruby_china.#{name}", num)
end

