class AddServicesToUser < ActiveRecord::Migration
  def up
  	add_column :users, :services, :string, :limit => 30
  	add_column :user_checkings, :service, :string, :limit => 20
  	remove_column :user_checkings, :service_id
  	drop_table :services
  	drop_table :services_users
  end

  def down

  	remove_column :users, :services
  	remove_column :user_checkings, :service
  	add_column :user_checkings, :service_id, :integer
    create_table :services do |t|
      t.string :name, null: false
      t.string :service_type
      t.timestamps
    end
  	create_table :services_users do |t|
      t.belongs_to :user
      t.belongs_to :service
    end
  end
end
