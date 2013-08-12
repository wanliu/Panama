module MessageQueue
  module Activity
    def new_activity_notice
      name = "#{routing_key}.expired"
      client.queue(name, :auto_delete => true)
      exchange = client.default_exchange
      exchange.publish(id.to_s, :routing_key => name)
    end

    private
    def routing_key
      "activity.notice"
    end

    def client
      Rabbitmq.client
    end
  end
end