require 'faye'
require "redis"
require 'yaml'

Faye::WebSocket.load_adapter('thin')

config = YAML.load_file("config/application.yml")[ENV['RACK_ENV']]
FAYE_TOKEN = config["faye_token"]
REDIS_PORT = config["redis_port"]
REDIS_SERVER = config["redis_server"]
REDIS_KEY = config["redis_key_prefix"]

redis = Redis.new(:host => REDIS_SERVER, :port => REDIS_PORT)

class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      puts message
      message = filter_data(message)
    end
    callback.call(message)
  end

  private
  def filter_data(message)
    if message['data']
      if message["data"].delete("token") != FAYE_TOKEN
        puts "Invalid authentication token..."
        message["data"]["values"] = 'Invalid authentication token'
      end
    end
    message["data"] = message["data"].delete("values")
    message
  end
end

faye_server = Faye::RackAdapter.new(:mount => '/realtime', :timeout => 45)
faye_server.add_extension(ServerAuth.new)

faye_server.bind(:unsubscribe) do |client_id, channel|
  reg = %r{^/chat/user/disconnect/(?<user_id>\w+)}
  if reg =~ channel
    m = reg.match(channel)
    key = "#{REDIS_KEY}#{m[:user_id]}"
    redis.del(key) if redis.exists(key)
    faye_server.get_client.publish("/chat/friend/disconnect/#{m[:user_id]}",
      {"token" => FAYE_TOKEN, "values" => m[:user_id]})
  end
end

run faye_server