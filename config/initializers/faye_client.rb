require 'net/http'

class FayeClient
  def self.send(channel, params)
    uri = URI.parse(Settings.defaults['faye_server'])
    token = Settings.defaults['faye_token']

    message = { :channel => channel, :data => {values: params, token: token} }
    Rails.logger.info message
    Thread.new do
      Net::HTTP.post_form(uri, :message => message.to_json)
    end
  end
end