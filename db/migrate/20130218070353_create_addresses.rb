class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :country
      t.string :zip_code
      t.string :road

      t.timestamps
    end
  end
end
