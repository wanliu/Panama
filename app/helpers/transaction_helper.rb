module TransactionHelper

  def get_token
    @transaction = current_order.find(params[:id])
    @transaction.temporary_channel.try(:token) || api_token
  end

  def api_token
    require 'net/http'  

    caramal_app_id = Settings.caramal_api_token
    caramal_host   = Settings.caramal_api_server

    begin
      url = get_temporary_token_url(caramal_host, caramal_app_id, @transaction)
      url_str = URI.parse(url)
      site = Net::HTTP.new(url_str.host, url_str.port)
      site.open_timeout = 0.2
      site.read_timeout = 0.2
      path = url_str.query.blank? ? url_str.path : url_str.path + "?" + url_str.query
      response = site.get2(path, {'accept'=>'text/json'})
      response = JSON.parse(response.body)
    rescue Exception => ex
      puts "Error: #{ex}"
      response = {}
    end
    response['token']
  end

  def get_temporary_token_url(caramal_host, caramal_app_id, transaction)
    "#{caramal_host}/api/#{caramal_app_id}/group_token/" <<
        "#{transaction.class.to_s}_#{transaction.number}"
  end
end