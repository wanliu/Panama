class Template
  cattr_accessor :shop

  attr_accessor :name, :path, :created_at, :updated_at, :data

  def initialize(name = nil, file_storage = nil)
    unless name.blank?
      @name = name
      fs = file_storage || shop.fs
      @fs = fs["templates/#{@name}.html.erb"]
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
    [@name]
  end

  def self.model_name
    ActiveModel::Name.new(self)
  end

  def self.find(id, *args)
    new id, *args
  end

  def self.setup(shop)
    Template.shop = shop
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