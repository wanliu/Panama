require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|
  config.storage = :upyun
  config.upyun_username = "kaka"
  config.upyun_password = 'fdsafdsa'
  config.upyun_bucket = "panama"
  config.upyun_bucket_domain = "panama.b0.upaiyun.com"
end

require 'switch_carrierwave'