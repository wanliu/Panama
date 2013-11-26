#encoding: utf-8
namespace :user do

  MQ_PREFIX = 'wanliu_'

  def publish(key, data)

  end

  desc "sync user following channels"
  task :channels => :environment do
    host = Settings.defaults['rabbitmq']['host']

    conn = Bunny.new(:hostname => host)
    conn.start

    ch = conn.create_channel

    User.all.each do |user|
      channels = user.persistence_channels.map do |channel|
        {
          name: channel.user.login,
          type: 1
        }
      end

      info = {
        user: user.login,
        channels: channels
      }

      ch.default_exchange.publish info.to_json, :routing_key => MQ_PREFIX + 'update_channels'

    end

    conn.close
  end
end
