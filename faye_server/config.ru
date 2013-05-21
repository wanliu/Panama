require 'faye'
require 'faye/redis'
require 'debugger'
require "redis"
require 'yaml'
require 'logger'

Faye::WebSocket.load_adapter('thin')

config = YAML.load_file("config/application.yml")[ENV['RACK_ENV']]
_tokens = config["faye_token"]

FAYE_TOKENS = _tokens.is_a?(String) ?  [_tokens] : _tokens
REDIS_PORT = config["redis_port"]
REDIS_SERVER = config["redis_server"]
REDIS_KEY = config["redis_key_prefix"]

redis = Redis.new(:host => REDIS_SERVER, :port => REDIS_PORT)

class ServerAuth
  def incoming(message, callback)
    puts message
    if message['channel'] !~ %r{^/meta/}
      logger.info "message: #{message}"
      message = filter_data(message)
    end
    callback.call(message)
  end

  def logger
    @logger ||= Logger.new("log/faye_server.log")
  end

  private
  def filter_data(m)
    if data = m['data']
      unless data.is_a?(Hash) && FAYE_TOKENS.include?(data.delete("token"))
        logger.error "Invalid authentication token..."
        data = {"values" => 'Invalid authentication token'}
      end
    end
    m["data"] = data.delete("values")
    m
  end
end

server = Faye::RackAdapter.new(
  :mount => '/realtime',
  :timeout => 45,
   :engine  => {
    :type  => Faye::Redis,
    :host  => REDIS_SERVER,
    :port  => REDIS_PORT
  })

extension = ServerAuth.new

server.add_extension(extension)

server.bind(:unsubscribe) do |client_id, channel|
  reg = %r{^/chat/user/disconnect/(?<user_id>\w+)}
  if reg =~ channel
    m = reg.match(channel)
    extension.logger.info "=====disconnect: #{m[:user_id]}"
    key = "#{REDIS_KEY}#{m[:user_id]}"
    redis.del(key) if redis.exists(key)
    server.get_client.publish("/chat/friend/disconnect/#{m[:user_id]}",
      {"token" => FAYE_TOKENS[0], "values" => m[:user_id]})
  end
end

run server