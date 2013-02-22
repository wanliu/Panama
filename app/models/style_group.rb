class StyleGroup < ActiveRecord::Base
  attr_accessible :name

  belongs_to :product
  has_many :items, class_name: 'StyleItem', dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :product_id, message: "this stylegroup is exists already now for %{value}" }
  validates :product_id, presence: true

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
