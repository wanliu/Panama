require 'carrierwave/processing/mini_magick'
require 'carrierwave_uploader_version'

class CarrierWaveStorageFile < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    def store_dir
      "#{model.class.to_s.underscore}/#{mounted_as}"
    end

    def url(version_name = "")
      args = {}
      args = "t#{version_name.split("x").join}".to_sym unless version_name.blank?
      url = super(args)
      file_path = "#{ImageUploader.root.call}#{url}"
      File.exist?(file_path) ? url : default_url
    end

    def extension_white_list
      %w(jpg jpeg gif png)
    end

    def default_url
      _version_name = version_name ? "#{version_name}_" : ""
      "/default_img/#{_version_name}file_blank.gif"
    end

    CarrierWave::Uploader.version_names.each do | vname |
      xy = vname.split("x")
      return if xy.length <= 0
      xy.push(xy[0]) if xy.length <= 1

      version "t#{vname.split("x").join}".to_sym do
        process :resize_to_fill => xy.map{ | x | x.to_i }
      end
    end
end