#author: huxinghai
#describe: 图片大小版本

module CarrierWave::Uploader
  def self.version_names
    %w(20x20 30x30 240x240 100x100 120x90 140x140 160x120 250x187 420x420 320 640 800)
  end
end