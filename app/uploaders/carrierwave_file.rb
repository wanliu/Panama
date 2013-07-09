require 'carrierwave/processing/mini_magick'
require 'carrierwave_uploader_version'

class CarrierWaveStorageFile < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  attr_accessor :default_file

  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}"
  end

  def url(version_name = "")
    url = super({})
    unless version_name.blank?
      version_name = version_name.split("x").join
      file_name = File.basename(url)
      url.gsub!(/#{file_name}/, "t#{version_name}_#{file_name}")
    end
    url
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def default_url
    _version_name = version_name ? "t#{version_name}_" : ""
    "/default_img/#{_version_name}#{default_file}"
  end

  def filename
    if super.present?
      model.uploader_secure_token ||= SecureRandom.uuid.gsub("-","")
      Rails.logger.debug("(BaseUploader.filename) #{model.uploader_secure_token}")
      "#{model.uploader_secure_token}.#{file.extension.downcase}"
    end
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