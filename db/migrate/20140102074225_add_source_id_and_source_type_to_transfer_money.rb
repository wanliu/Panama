class AddSourceIdAndSourceTypeToTransferMoney < ActiveRecord::Migration
  def change
    add_column :transfer_moneys, :source_id, :integer
    add_column :transfer_moneys, :source_type, :string
  end
end
