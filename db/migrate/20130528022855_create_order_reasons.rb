class CreateOrderReasons < ActiveRecord::Migration
  def change
    create_table :order_reasons do |t|
      t.string :name

      t.timestamps
    end
  end
end
