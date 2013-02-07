class StyleGroup
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String

  has_many :items, :dependent => :destroy, :class_name => "StyleItem"

  belongs_to :product

  def has?(name)
    the_filter = items.select{|item| item['title'] == name}
    return the_filter.blank?
  end

  def add_item(title, value=nil)
    value ||= title
    items.build(:title => title, :value => value)
  end

  def add_colour_item(color, rgb)
    rgb = if rgb.is_a?(Array)
      r, g , b = *rgb
      rgb = (r << 16) + (g << 8) + b
      "#%x" % rgb
    end

    add_item(color, rgb)
  end

  def add_size_item(title)
    add_item(title, title)
  end

end