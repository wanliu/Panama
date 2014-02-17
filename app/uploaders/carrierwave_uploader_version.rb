#author: huxinghai
#describe: 图片大小版本

module CarrierWave::Uploader
  def self.version_names
    %w(20x20 30x30 50x50 100x100 240x240 420x420)
  end
end