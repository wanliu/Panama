class ClearColumnFromAddress < ActiveRecord::Migration
  def change
		remove_column :addresses, :user_id
		remove_column :addresses, :transaction_id
		remove_column :addresses, :country

		rename_column :addresses, :addressable_id, :targeable_id
		rename_column :addresses, :addressable_type, :targeable_type
  end
end