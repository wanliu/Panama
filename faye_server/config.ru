require 'faye'
require "redis"
require 'yaml'

Faye::WebSocket.load_adapter('thin')

config = YAML.load_file("config/application.yml")[ENV['RACK_ENV']]
FAYE_TOKEN = config["faye_token"]
REDIS_PORT = config["redis_port"]
REDIS_SERVER = config["redis_server"]

redis = Redis.new(:host => REDIS_SERVER, :port => REDIS_PORT)

def filter_data(message)
  if message['data']
    if message['token'] != FAYE_TOKEN
      puts "Invalid authentication token..."
      message = 'Invalid authentication token'
    else
      message.delete("token")
    end
  end
  message
end

class ServerAuth
  def incoming(message, callback)
    puts message
    if message['channel'] !~ %r{^/meta/}
      message = filter_data(message)
    end
    callback.call(message)
  end
end

faye_server = Faye::RackAdapter.new(:mount => '/realtime', :timeout => 45)
faye_server.add_extension(ServerAuth.new)

faye_server.bind(:unsubscribe) do |client_id, channel|
  puts "#{client_id} disconnected from #{channel}"

  reg = %r{^/chat/user/disconnect/(?<user_id>\w+)}
  if reg =~ channel
    m = reg.match(channel)
    key = "online_user_#{m[:user_id]}"
    redis.del(key) if redis.exists(key) > 0
    faye_server.get_client.publish("/chat/friend/disconnect/#{m[:user_id]}",
      {:token => FAYE_TOKEN})
  end
end

run faye_server