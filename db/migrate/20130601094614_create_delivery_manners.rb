class CreateDeliveryManners < ActiveRecord::Migration
  def change
    create_table :delivery_manners do |t|
      t.string :code
      t.string :name
      t.boolean :state, :default => true

      t.timestamps
    end
  end
end
