class Cart < ActiveRecord::Base
  attr_accessible :items_count

  belongs_to :user
  has_many :items, inverse_of: :cart, class_name: 'ProductItem', autosave: true

  def add_to(attributes, be_merge = true)
    product_id = attributes[:product_id]
    item = exist_build_options(product_id, attributes) do |_item|
      _item.amount += attributes[:amount].to_d
    end
    item.total = item.price * item.amount
    item
  end

  def exist_build(product_id, attributes, &block)
    if item = items.where(:product_id => product_id).first
      yield item
      item
    else
      items.build attributes
    end
  end

  def exist_build_options(product_id, attributes, be_merge = true, &block)
    if be_merge
      exist_build product_id, attributes, &block
    else
      items.build attributes
    end
  end
end
