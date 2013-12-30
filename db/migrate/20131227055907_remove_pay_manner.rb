class RemovePayManner < ActiveRecord::Migration
  def change
  	drop_table :pay_manners
  end
end
