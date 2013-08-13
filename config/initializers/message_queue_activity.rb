module MessageQueue
  module Activity

    private
    def routing_key
      "activity.notice"
    end

    def client
      Rabbitmq.client
    end
  end
end