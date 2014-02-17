class AddProductsAddedAndRejectedAndRejecteReasonToUserChecking < ActiveRecord::Migration
  def change
  	add_column :user_checkings, :products_added, :boolean, default: false
  	add_column :user_checkings, :rejected, :boolean, default: false
  	add_column :user_checkings, :rejected_reason, :string
  end
end
