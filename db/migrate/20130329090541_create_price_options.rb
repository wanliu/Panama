class CreatePriceOptions < ActiveRecord::Migration
  def change
    create_table :price_options do |t|
      t.string  :name
      t.string  :title
      t.integer :property_id
      t.references :optionable, :polymorphic => true
      t.timestamps
    end
  end
end
