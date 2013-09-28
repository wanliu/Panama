class AddDeletedAtToAddresses < ActiveRecord::Migration
  def change
  	add_column :addresses, :deleted_at, :time
  end
end
