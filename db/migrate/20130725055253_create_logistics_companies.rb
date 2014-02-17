class CreateLogisticsCompanies < ActiveRecord::Migration
  def change
    create_table :logistics_companies do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
