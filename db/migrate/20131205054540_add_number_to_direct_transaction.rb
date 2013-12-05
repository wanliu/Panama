class AddNumberToDirectTransaction < ActiveRecord::Migration
  def change
    add_column :direct_transactions, :number, :string
  end
end
