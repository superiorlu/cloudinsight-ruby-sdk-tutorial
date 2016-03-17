# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
 app_root = File.expand_path('../', File.dirname(__FILE__))

 set :output, "#{app_root}/cron_log.log"

#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

ruby_path =  `which ruby`.chop
job_type  :sh, "cd #{app_root} && #{ruby_path} :task :output"


every 1.minute do 
   sh "weather.rb"
end


 every 5.minutes  do
   sh "ruby_china.rb" 
 end

