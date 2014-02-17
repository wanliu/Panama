class CreateProductPropertyValues < ActiveRecord::Migration
  def change
    create_table :product_property_values do |t|
      t.integer  :product_id
      t.integer  :property_id
      t.string   :svalue
      t.integer  :nvalue
      t.decimal  :dvalue,  :precision => 20, :scale => 10
      t.datetime :dtvalue

      t.timestamps
    end
  end
end
