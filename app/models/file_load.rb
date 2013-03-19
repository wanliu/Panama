class FileLoad

  cattr_accessor :shop

  attr_accessor  :name, :data

  def initialize(file_path = nil)
    unless file_path.blank?
      @file_path = file_path      
      fs = '/'.to_dir
      @fs = fs[@file_path]
    end
  end

  def data
    @fs.read
  end

  def data=(value)
    @fs.write(value)
  end
end