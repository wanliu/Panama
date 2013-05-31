module MessageQueue
  module OrderRefund
    def apply_failure_notice
      name = "#{routing_key}.expired"
      client.queue(name, :auto_delete => true)
      exchange = client.default_exchange
      exchange.publish(id.to_s, :routing_key => name)
    end

    private
    def routing_key
      "order_refund.notice"
    end

    def client
      Rabbitmq.client
    end
  end
end