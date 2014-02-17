class AddShopCategoryAttachmentToProduct < ActiveRecord::Migration
  def change
    add_column :products, :shop_id, :integer
    add_column :products, :category_id, :integer
    add_column :products, :default_attachment_id, :integer
  end
end
