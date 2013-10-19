class CreateDeliveryAddresses < ActiveRecord::Migration
  def change
    create_table :delivery_addresses do |t|
      t.integer :user_id
      t.string :zip_code
      t.string :road
      t.integer :province_id
      t.integer :city_id
      t.integer :area_id
      t.string :contact_name
      t.string :contact_phone
      t.time :deleted_at

      t.timestamps
    end
  end
end
