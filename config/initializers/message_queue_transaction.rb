module MessageQueue
  module Transaction
    extend ::ActiveSupport::Concern

    module InstanceMethods

      def notice_system_manage(message)
        name = "#{routing_key}.system"
        client.queue(name, :auto_delete => true)
        exchange = client.default_exchange
        exchange.publish(message, :routing_key => name)
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
end