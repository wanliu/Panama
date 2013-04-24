require 'net/http'

class FayeClient
  def self.send(channel, params)
  	puts params
    Thread.new do
      uri = URI.parse(Settings.defaults['faye_server'])
      token = Settings.defaults['faye_token']
      message = { :channel => channel, :data => params.merge(:token => token) }
      puts message
      Net::HTTP.post_form(uri, :message => message.to_json)
    end
  end
end