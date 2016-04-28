# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
# Learn more: http://github.com/javan/whenever

set :app_path, File.expand_path('../', File.dirname(__FILE__))
set :output, 'log/crontab.log'
set :ruby_path, `which ruby`.chop

job_type :sh, 'cd :app_path && :ruby_path :task :output'

every 1.minute do
  sh 'lib/weather.rb'
end

every 5.minutes do
  sh 'lib/ruby_china.rb'
end

every 30.minutes do
  sh 'lib/fangjia.rb'
end
