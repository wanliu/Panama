class AddActivedToShops < ActiveRecord::Migration
  def change
    add_column :shops, :actived, :boolean, default: false
  end
end
