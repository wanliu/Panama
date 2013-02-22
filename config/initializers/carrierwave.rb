require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|
  config.storage = :upyun
  config.upyun_username = "hysios"
  config.upyun_password = 'asdfasdf'
  config.upyun_bucket = "panama-img"
  config.upyun_bucket_domain = "panama-img.b0.upaiyun.com"
end

require 'switch_carrierwave'