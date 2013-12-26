require "bunny"

module Rabbitmq
  class MQClient

    def initialize
      @conn ||= Bunny.new(options)
      @conn.start unless @conn.status == :connected
      @ch ||= @conn.create_channel
    end

    def channel
      @ch
    end

    def connect
      @conn
    end

    def queue(key, options = {})
      channel.queue key, options
    end

    def subscribe(key, &block)
      if block_given?
        queue(key).subscribe do |*args|
          yield *args
        end
      else
        puts "error: not block?"
      end
    end

    def publish(key, message)
      default_exchange.publish(key, message)
    end

    def default_exchange
      channel.default_exchange
    end

    def direct(name, options = {})
      channel.direct name, options
    end

    def fanout(name, options = {})
      channel.fanout name, options
    end

    def topic(name, options = {})
      channel.topic name, options
    end

    private
    def options
      _opts = (Settings.rabbitmq {}).symbolize_keys
      _opts[:heartbeat] = _opts[:heartbeat].to_sym if _opts.key?(:heartbeat)
      _opts
    end
  end

  def self.client
    @client ||= MQClient.new
  end
end