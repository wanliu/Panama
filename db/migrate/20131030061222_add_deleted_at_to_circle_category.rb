class AddDeletedAtToCircleCategory < ActiveRecord::Migration
  def change
  	add_column :circle_categories, :deleted_at, :time
  end
end
