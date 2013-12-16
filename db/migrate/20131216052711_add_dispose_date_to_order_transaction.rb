class AddDisposeDateToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :dispose_date, :datetime
  end
end
