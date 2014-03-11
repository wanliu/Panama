#encoding: utf-8
namespace :user do

  MQ_PREFIX = 'wanliu_'

  def publish(key, data)

  end

  desc "sync user following channels"
  task :channels => :environment do
    host = Settings.rabbitmq['host']

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

  desc "recreate temporary channel"
  task :create_temporary_channels => :environment do
    targets = [ OrderTransaction, DirectTransaction ]
    targets.each do |target|
      target.all.each do |o|
        name = o.class.to_s << "_" << o.number 
        if o.temporary_channel.present?
          o.temporary_channel.delete
        end
        o.create_temporary_channel(targeable_type: o.class.to_s, user_id: o.seller.owner.id, name: name)
        # o.send('create_the_temporary_channel')
      end
    end
  end
end
