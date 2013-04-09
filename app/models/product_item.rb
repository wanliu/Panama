class ProductItem < ActiveRecord::Base
  include PanamaCore::DynamicProperty

  attr_accessible :amount, :price, :title, :total, :transaction_id, :cart, :product_id


  has_and_belongs_to_many   :properties
  has_many                  :properties_values,
                            :class_name => "PropertyValue",
                            :as         => :valuable,
                            :autosave   => true,
                            :dependent  => :delete_all

  has_and_belongs_to_many   :property_items,
                            :select => ['property_items.*',
                                        'product_items_property_items.id as products_items_property_items_id',
                                        'product_items_property_items.title'],
                            :autosave => true


  belongs_to :cart, inverse_of: :items, :counter_cache => :items_count
  belongs_to :product
  belongs_to :transaction,
             class_name: "OrderTransaction",
             primary_key: 'transaction_id'

  delegate :photos, :to => :product
  delegate :icon, :header, :avatar, :preview, :to => :photos

  # validates :sub_product_id, presence: true

end
