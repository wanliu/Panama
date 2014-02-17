class AddBrandNameToProduct < ActiveRecord::Migration
  def change
    add_column :products, :brand_name, :string
  end
end
