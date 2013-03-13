class AppFile

  attr_accessor :name, :data
  
  # def data=(value)
  #   write_attribute(:data, value)
  # end
 
end


class FileLoad

  cattr_accessor :shop

  attr_accessor  :data

  def initialize(file_path = nil)
    debugger
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