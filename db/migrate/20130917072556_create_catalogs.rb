class CreateCatalogs < ActiveRecord::Migration
  def change
    create_table :catalogs do |t|
      t.string :title
      t.timestamps
    end

    create_table :catalogs_categories do |t|
    	t.belongs_to :catalog
    	t.belongs_to :category
    end
  end
end
