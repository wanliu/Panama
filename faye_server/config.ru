require 'faye'
require 'yaml'

Faye::WebSocket.load_adapter('thin')

config = YAML.load_file("config/application.yml")[ENV['RACK_ENV']]
FAYE_TOKEN = config["faye_token"]

class ServerAuth
  def incoming(message, callback)
    puts message
    if message['channel'] !~ %r{^/meta/}
        if message['data']
            if message['data']['token'] != FAYE_TOKEN
                puts "Invalid authentication token..."
                message['error'] = 'Invalid authentication token'
            else
                message['data'].delete("token")
            end
        end
    end
    callback.call(message)
  end
end

faye_server = Faye::RackAdapter.new(:mount => '/realtime', :timeout => 45)
faye_server.add_extension(ServerAuth.new)
run faye_server