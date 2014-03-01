require 'yaml'
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
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
config = YAML::load_file("#{path}/config/whenever.yml")
set :output, "~/whenever.log"
set :environment, config["environment"]

every 5.minutes do
  runner "OrderTransaction.state_expired"
end

every 5.minutes do
  runner "OrderRefund.state_expired"
end

every 5.minutes do
  runner "DirectTransaction.expired_state"
end