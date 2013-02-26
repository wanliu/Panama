class Cart < ActiveRecord::Base
  attr_accessible :items_count

  belongs_to :user
  has_many :items, inverse_of: :cart, class_name: 'ProductItem', autosave: true  

  def create_transaction(people)
  	done = shop_items.map { |shop, items| save_transcation(shop, items, people) }.all?
  	destroy if done # FIXME :should't be items.clear?
  	done
  end

  def shop_items
  	items.group_by { |item| item.product.shop }
  end

  def save_transcation(shop, items, people)
  	transaction = people.transactions.build seller_id: shop.id
    items.each {|item| transaction.items.build item.attributes }
    transaction.items_count = items.inject(0) { |s, item| s + item.amount }
    transaction.total = items.inject(0) { |s, item| s + item.total }
    transaction.save
  end
end
