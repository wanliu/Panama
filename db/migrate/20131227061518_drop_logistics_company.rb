class DropLogisticsCompany < ActiveRecord::Migration
  def change
  	drop_table :logistics_companies
  end
end
