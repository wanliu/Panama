class AddProductIdToProductComment < ActiveRecord::Migration
  def change
    add_column :product_comments, :product_id, :integer
  end
end
