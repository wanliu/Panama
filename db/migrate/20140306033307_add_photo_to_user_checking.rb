class AddPhotoToUserChecking < ActiveRecord::Migration
  def change
  	add_column :user_checkings, :shop_photo, :string
  end
end
