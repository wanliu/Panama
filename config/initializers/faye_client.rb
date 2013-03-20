require 'net/http'

class FayeClient
    def self.send(channel, params)
        Thread.new do
            uri = URI.parse(Settings.defaults['faye_server'])
            token = Settings.defaults['faye_token']
            message = { :channel => channel, :data => { :token => token }.merge(params) }
            Net::HTTP.post_form(uri, :message => message.to_json)
        end
    end
end