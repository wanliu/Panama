class CreatePayManners < ActiveRecord::Migration
  def change
    create_table :pay_manners do |t|
      t.string :name
      t.text :description
      t.boolean :state, :default => true

      t.timestamps
    end
  end
end
