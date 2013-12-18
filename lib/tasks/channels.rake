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
      channels = user.persistent_channels.map do |channel|
        role = ""
        if 2 == channel.channel_type
          circle = Circle.where(name: channel.name).first
          if circle && circle.is_owner_people?(user)
            role = "Owner"
          end
        end
        { name: channel.name, type: channel.channel_type, role: role}
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
