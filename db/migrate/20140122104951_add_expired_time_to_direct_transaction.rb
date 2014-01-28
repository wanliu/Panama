class AddExpiredTimeToDirectTransaction < ActiveRecord::Migration
  def change
    add_column :direct_transactions, :expired_time, :datetime
  end
end
