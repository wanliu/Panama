class AddTransactionToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :transaction_id, :integer
    add_column :addresses, :user_id, :integer
    add_column :addresses, :province_id, :integer
    add_column :addresses, :city_id, :integer
    add_column :addresses, :area_id, :integer
    add_column :addresses, :addressable_id, :integer
    add_column :addresses, :addressable_type, :string
  end
end
