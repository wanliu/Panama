class CreateActivityRules < ActiveRecord::Migration
  def change
    create_table :activity_rules do |t|
      t.string :name, :limit => 25
      t.string :value, :limit => 25
      t.timestamps
    end
  end
end
