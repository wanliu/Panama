class AddDeletedToUserBank < ActiveRecord::Migration
  def change
  	add_column :user_banks, :deleted_at, :time
  end
end
