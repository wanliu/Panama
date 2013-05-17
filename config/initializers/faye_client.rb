class FayeClient
  def self.send(channel, params)
    token = Settings.defaults['faye_token']
    publish = connect.publish(channel, {values: params, token: token})
  end

  def self.receive(channel, &block)
    connect.subscribe(channel) do |data|
      puts "==============client_receive: #{data}"
      yield data
    end
  end

  class << self

    private
    def connect
      @client ||= Faye::Client.new(Settings.defaults['faye_server'])
      @client
    end
  end

end