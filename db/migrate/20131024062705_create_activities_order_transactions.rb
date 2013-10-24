class CreateActivitiesOrderTransactions < ActiveRecord::Migration
  def change
    create_table :activities_order_transactions do |t|
      t.integer :activity_id
      t.integer :order_transaction_id
      t.timestamps
    end
  end
end
