# encoding: utf-8
require 'carrierwave_file'
require 'carrierwave_upyun'

CarrierWave.configure do | c |
  class ImageUploader < Kernel.const_get(c.storage.name.gsub(/::/, ""))
  end
end
