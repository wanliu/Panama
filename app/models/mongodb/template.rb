# virtual Template class
# 
class Mongodb::Template
  cattr_accessor :shop

  attr_accessor :name, :path, :created_at, :updated_at, :data

  def initialize(name = nil)
    if name.blank?
    else
      @name = name
      @fs = shop.fs["templates/#{@name}.html.erb"]
    end
  end

  def new_record?
    !(@fs && (@fs.file? or @fs.dir?))
  end

  def persisted?
    @fs && (@fs.file? or @fs.dir?)
  end

  def data
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

  def self.find(id)
    new id
  end

  def self.setup(shop)
    Template.shop = shop
  end
end