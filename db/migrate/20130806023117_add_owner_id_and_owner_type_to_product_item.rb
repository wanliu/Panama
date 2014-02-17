class AddOwnerIdAndOwnerTypeToProductItem < ActiveRecord::Migration
  def change
    add_column :product_items, :owner_id, :integer
    add_column :product_items, :owner_type, :string
  end
end
