require 'net/http'
require 'json'

module IPSearch
  def self.ip_query(client_ip)
    params = {
        ip: client_ip,
        ak: "9ea9e7c2b39e280953800845b2753fa6" #百度的key
    }
    uri = URI.parse("http://api.map.baidu.com/location/ip?") 
    begin
        res = Net::HTTP.post_form(uri, params)
        JSON.parse(res.body) || {}
    rescue Exception => e
        {}
    end     
  end
end