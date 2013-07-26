class CreateUsersAndServices < ActiveRecord::Migration
  def up
  	create_table :services_users do |t|
      t.belongs_to :user
      t.belongs_to :service
    end
  end

  def down
  end
end
