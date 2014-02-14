class Cart < ActiveRecord::Base
  attr_accessible :items_count

  belongs_to :user

  has_many :items, inverse_of: :cart, class_name: 'ProductItem', autosave: true

  def add_to(attributes, be_merge = true)
    product_id = attributes[:product_id]
    shop_id = attributes[:shop_id]
    item = exist_build_options(shop_id, product_id, attributes) do |_item|
      _item.amount += attributes[:amount].to_d
    end
    item.total = item.price * item.amount
    item
  end

  def exist_build(shop_id, product_id, attributes, &block)
    buy_state = ProductItem._get_state_val attributes[:buy_state]
    if item = items.find_by(
      :buy_state => buy_state,
      :shop_id => shop_id,
      :product_id => product_id)
      yield item
      item
    else
      @product = Product.find(product_id)
      @item = items.build attributes.slice(:title, :price, :amount)
      @product.prices_definition.each do |prop|
        @item.properties << prop
      end
      # @item.delegate_property_setup
      attributes.each do |k, v|
        @item.send("#{k}=", v)
      end
      @item
    end
  end

  def exist_build_options(shop_id, product_id, attributes, be_merge = true, &block)
    if be_merge
      exist_build shop_id, product_id, attributes, &block
    else
      items.build attributes
    end
  end

  def create_transaction(people, item_ids)
    done = cart_items(item_ids).map do |header, pro_items|
      if header[:buy_state] == :guarantee
        save_transcation(header[:shop], pro_items, people)
      else
        create_direct_transaction(header[:shop], pro_items, people)
      end
    end.all?
    items.where("id in (?)", item_ids).update_all(cart_id: nil) if done # FIXME :should't be items.clear?
    done
  end

  def cart_items(item_ids = [])
    items.where("id in (?)", item_ids).group_by { |item| {shop: item.shop, buy_state: item.buy_state.name} }
  end

  def shop_items
    items.group_by { |item| {shop: item.shop, buy_state: item.buy_state.name} }
  end

  def save_transcation(shop, pro_items, people)
    transaction = people.transactions.build(seller_id: shop.id)
    transaction.items = pro_items    
    state = transaction.save  
    errors_build(transaction) unless state        
    state
  end

  def create_direct_transaction(shop, pro_items, people)
    transaction = people.direct_transactions.build(seller_id: shop.id)
    transaction.items = pro_items
    state = transaction.save
    errors_build(transaction) unless state
    state
  end

  private
  def errors_build(model)
    model.errors.messages.each do |k, v| 
      v.each{|e| errors.add(k, e) }      
    end
  end
end
