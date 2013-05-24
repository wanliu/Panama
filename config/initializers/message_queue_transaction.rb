module MessageQueue
  module Transaction
    def not_service_online(message)
      name = "#{routing_key}.not.service"
      client.queue(name, :auto_delete => true)
      exchange = client.default_exchange
      exchange.publish(message, :routing_key => name)
    end

    def expired_delivery_failer
      name = "#{routing_key}.expired.delivery.failer"
      client.queue(name, :auto_delete => true)
      exchange = client.default_exchange
      exchange.publish(id.to_s, :routing_key => name)
    end

    private
    def routing_key
      "transaction.notice"
    end

    def client
      Rabbitmq.client
    end
  end
end