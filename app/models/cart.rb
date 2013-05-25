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
      @product = Product.find(product_id)
      @item = items.build attributes.slice(:title, :price, :amount)
      @product.prices_definition.each do |prop|
        @item.properties << prop
      end
      @item.delegate_property_setup
      attributes.each do |k, v|
        @item.send("#{k}=", v)
      end
      @item
    end
  end

  def exist_build_options(product_id, attributes, be_merge = true, &block)
    if be_merge
      exist_build product_id, attributes, &block
    else
      items.build attributes
    end
  end

  def create_transaction(people)
    done = shop_items.map { |shop, pro_items| save_transcation(shop, pro_items, people) }.all?
    destroy if done # FIXME :should't be items.clear?
    done
  end

  def shop_items
    items.group_by { |item| item.product.shop }
  end

  def save_transcation(shop, pro_items, people)
    transaction = people.transactions.build(seller_id: shop.id)
    transaction.items = pro_items
    transaction.save
  end



end
