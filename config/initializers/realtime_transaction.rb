module Realtime
  module Transaction
    extend ::ActiveSupport::Concern

    module InstanceMethods

      def im_name
        "transaction"
      end

      def buyer_send_message(message)
        _exchange.publish(message, :routing_key => "#{im_name}.#{self.id}.seller")
      end

      def seller_send_message(message)
        _exchange.publish(message, :routing_key => "#{im_name}.#{self.id}.buyer")
      end

      def _exchange
        Rabbitmq.client.direct("#{im_name}.chat.message")
      end

    end
  end
end