class AddImTokenToShop < ActiveRecord::Migration
  def change
    add_column :shops, :im_token, :string
  end
end
