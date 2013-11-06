class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :name
      t.timestamps
    end

    create_table :region_cities do |t|
      t.integer :city_id
      t.integer :region_id
      t.timestamps
    end

    create_table :region_pictures do |t|
    	t.integer :region_id
    	t.integer :attachment_id
    	t.timestamps
    end
  end
end
