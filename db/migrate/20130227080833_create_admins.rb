class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
      t.string :uid
      t.string :login

      t.timestamps
    end
  end
end
