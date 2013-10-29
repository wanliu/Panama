class AddAdvertisementToRegion < ActiveRecord::Migration
  def change
  	add_column :regions, :advertisement, :text
  end
end
