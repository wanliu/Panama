class AddActivityPriceAndActivityNameToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :activity_price, :decimal, :precision => 10, :scale => 2
  end
end
