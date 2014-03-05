require 'bunny'
require 'json'

class CaramalClient
  MQ_PREFIX = 'wanliu_'
  # login: String 用户名
  # channel: 频道名
  # msg:  消息， 消息格式 Hash
  # 例子:
  #     require 'caramal_client'
  #     CaramalClient.publish('hysios', '/transcations', {:id => 1234 })


  def self.publish(login, channel, msg = {})

    conn = Bunny.new(:hostname =>  ENV["rabbitmq"])
    conn.start
    
    info = {
      login: login,
      channel: "notify:#{channel}",
      msg: msg
    }


    ch = conn.create_channel
    ch.default_exchange.publish info.to_json, :routing_key => MQ_PREFIX + 'notification'
    ch.close
    conn.stop
  end

  def self.create_temporary_channel(name, owner, options={}, &block)
    conn = Bunny.new(:hostname =>  ENV["rabbitmq"])
    conn.start

    data = {:name => name, :owner => owner}
    data.merge!(options)
    data = data.to_json

    ch  = conn.create_channel
    x = ch.default_exchange

    mq_prefix = 'wanliu_'

    corrid = SecureRandom.hex

    q = ch.queue("", { :exclusive => true })

    consumer = Bunny::Consumer.new(ch, q)
    over = false
    msg = 'X'
    consumer.on_delivery do |delivery_info, properties, payload|
      if properties[:correlation_id] == corrid
        puts payload
        msg = payload

        block.call(msg) if block_given?

        ch.consumers[delivery_info.consumer_tag].cancel
        ch.close
        conn.stop
      end
    end

    x.publish(data, :routing_key => mq_prefix + 'rpc_create_temporary_channel', correlation_id: corrid, reply_to: q.name)
    # sleep 10
    q.subscribe_with(consumer)

  end


  def self.remove_temporary_channel(name, owner, &block)
    conn = Bunny.new(:hostname =>  ENV["rabbitmq"])
    conn.start

    data = {:name => name, :owner => owner}.to_json
    ch  = conn.create_channel
    x = ch.default_exchange

    mq_prefix = 'wanliu_'

    corrid = SecureRandom.hex

    q = ch.queue("", { :exclusive => true })

    consumer = Bunny::Consumer.new(ch, q)
    over = false
    msg = 'X'
    consumer.on_delivery do |delivery_info, properties, payload|
      if properties[:correlation_id] == corrid
        puts payload
        msg = payload

        block.call(msg) if block_given?

        ch.consumers[delivery_info.consumer_tag].cancel
        ch.close
        conn.stop
      end
    end

    x.publish(data, :routing_key => mq_prefix + 'rpc_remove_temporary_channel', correlation_id: corrid, reply_to: q.name)
    # sleep 10
    q.subscribe_with(consumer)

  end

  def self.create_persistent_channel(group, user, type, role=nil)
    conn = Bunny.new(:hostname =>  ENV["rabbitmq"])
    conn.start

    data = {:group => group, :user => user, :type => type}
    data[:role] = "Owner" if 'Owner' == role
    data = data.to_json

    ch  = conn.create_channel
    x = ch.default_exchange

    mq_prefix = 'wanliu_'

    q = ch.queue("", { :exclusive => true })

    x.publish(data, :routing_key => mq_prefix + 'rpc_create_persistent_channel')
    conn.stop
  end

  def self.remove_persistent_channel(group, user, type)
    conn = Bunny.new(:hostname =>  ENV["rabbitmq"])
    conn.start

    data = {:group => group, :user => user, :type => type}.to_json
    ch  = conn.create_channel
    x = ch.default_exchange

    mq_prefix = 'wanliu_'

    q = ch.queue("", { :exclusive => true })

    x.publish(data, :routing_key => mq_prefix + 'rpc_remove_persistent_channel')
    conn.stop
  end

  def self.create_shop_employee(shop, user, role)
    conn = Bunny.new(:hostname =>  ENV["rabbitmq"])
    conn.start

    data = { :shop => shop, :user => user, :role => role }
    data = data.to_json

    ch  = conn.create_channel
    x = ch.default_exchange
    mq_prefix = 'wanliu_'
    q = ch.queue("", { :exclusive => true })

    x.publish(data, :routing_key => mq_prefix + 'rpc_create_shop_employee')
    conn.stop
  end

  def self.remove_shop_employee(shop, user, role)
    conn = Bunny.new(:hostname =>  ENV["rabbitmq"])
    conn.start

    data = { :shop => shop, :user => user, :role => role }
    data = data.to_json

    ch  = conn.create_channel
    x = ch.default_exchange
    mq_prefix = 'wanliu_'
    q = ch.queue("", { :exclusive => true })

    x.publish(data, :routing_key => mq_prefix + 'rpc_remove_shop_employee')
    conn.stop
  end
end
