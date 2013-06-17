# author: huxinghai
# describe: 切换上传服务器

module Carrierwave
  module Switch
    class << self
      def configure(&block)
        config = YAML::load_file("#{Rails.root}/config/switch_carrierwave.yml")
        storage = (config["upload_storage"] || "file").to_sym
        CarrierWave.configure{| config | config.storage = storage }
        yield(storage) if block_given?
      end
    end
  end
end

Carrierwave::Switch.configure