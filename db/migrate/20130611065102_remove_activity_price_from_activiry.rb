class RemoveActivityPriceFromActiviry < ActiveRecord::Migration
  def up
    remove_column :activities, :activity_price
  end

  def down
    add_column :activities, :activity_price, :string
  end
end
