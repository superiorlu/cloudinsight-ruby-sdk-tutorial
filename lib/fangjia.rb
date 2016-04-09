#! /usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'oneapm_ci'
require_relative 'time_formater'

fangjia_page = Nokogiri::HTML(open('http://bj.lianjia.com/fangjia'))
  
areas = ['']

fangjia_page.css('#wrapperCon > div:nth-child(2) a').each do |area_info|
  area = /fangjia\/(?<name>.*)\/"/.match(area_info.to_s)
  areas << area[:name]
end

threads = []

areas.each do |area|
  threads << Thread.new do 
    fangjia = {}
    css = {}
    statsd = OneapmCi::Statsd.new
    url = "http://bj.lianjia.com/fangjia/#{area}"
    puts url
    area_fangjia_page = Nokogiri::HTML(open(url))
    if area.empty? #beijing special
      css[:saled] = 'div.display-block.fl > div.bottom > div.second.fl > span'
      css[:visited] = 'div.display-block.fl > div.bottom > div.third.fl > span'
    end
    fangjia = search_info area_fangjia_page, css
    fangjia.each do |name, info|
      next if info.nil? || info.empty?
      area = area.empty? ? 'beijing' : area
      puts "#{TimeFormater.now} area:#{area} #{name}:#{info}"
      statsd.gauge("bj.fangjia.#{area}.#{name}", info)
    end
  end
end

def search_info page, css = {}
  {}.tap do |fangjia|
    fangjia[:price] = page.css('#properties-listed-count').text # 均价 元/平米

    origin_fangyuan_info = page.css('div.display-block.fl > div.view > div > div > div > div.last > div > p:nth-child(1) > a').text
    fangyuan_info = /在售房源(?<num>.*)套/.match(origin_fangyuan_info)
    puts "WARNING origin_fangyuan_info: #{origin_fangyuan_info}" unless fangyuan_info
    fangjia[:fangyuan] = fangyuan_info && fangyuan_info[:num] # 在售房源

    origin_saled_info = page.css('div.display-block.fl > div.view > div > div > div > div.last > div > p:nth-child(2) > a').text
    saled_info = /成交房源(?<num>.*)套/.match(origin_saled_info)
    puts "WARNING saled_info: #{saled_info}" unless saled_info
    fangjia[:saled] = saled_info && saled_info[:num] # 最近90天内成交房源

    fangjia[:kefang_yesterday] = page.css('div.display-block.fl > div.bottom > div.first.fl > span').text # 昨日新增客房比-城市范围

    saled_css = css[:saled] ? css[:saled] : 'div.display-block.fl > div.bottom > div:nth-child(1) > span'
    fangjia[:saled_yesterday] = page.css(saled_css).text # 昨日成交量/套

    visited_css = css[:visited] ? css[:visited] : 'div.display-block.fl > div.bottom > div:nth-child(3) > span'
    fangjia[:visited] = page.css(visited_css).text # 昨日房源带看量/次
  end
end

threads.each(&:join)
