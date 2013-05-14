class CreateProductDeliveryTypes < ActiveRecord::Migration
  def change
    create_table :product_delivery_types do |t|
      t.integer :product_id
      t.integer :delivery_type_id

      t.timestamps
    end
  end
end
