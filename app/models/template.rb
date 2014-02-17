# encoding: utf-8
#
class Template
  attr_accessor :name, :path, :created_at, :updated_at, :data

  def fs
    @fs
  end

  def initialize(name = nil, file_storage = nil)
    unless name.blank?
      @name = name
      fs = file_storage || '/'.to_dir
      @fs = fs[@name]
    end
  end

  def new_record?
    !(@fs && (@fs.file? or @fs.dir?))
  end

  def persisted?
    @fs && (@fs.file? or @fs.dir?)
  end

  def data
    @fs.write unless @fs.exist?
    @fs.read
  end

  def data=(value)
    @fs.write(value)
  end

  def to_key
    [File.basename(@name, '.html.erb')]
  end

  def path
    @fs.path
  end

  def self.model_name
    ActiveModel::Name.new(self)
  end

  def self.find(id, *args)
    new id, *args
  end

  def self.setup(shop)
    warning = "setup(shop: Shop) 方法已经废弃," +
              "请使用 Template.new(name: String, fs = nil:VFS) 这种方式创建 Template"
    ActiveSupport::Deprecation.warn(warning)
    # Template.shop = shop
  end

  def ==(other)
    if other.equal?(self)
      return true
    elsif !other.instance_of?(self.class)
      return false
    end
    if name == other.name
      @fs.path == other.instance_variable_get(:@fs).path
    end
  end
end