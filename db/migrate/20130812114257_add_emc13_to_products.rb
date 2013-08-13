class AddEmc13ToProducts < ActiveRecord::Migration
  def change
    add_column :products, :emc13, :string
  end
end
