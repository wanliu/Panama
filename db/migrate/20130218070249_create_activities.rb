class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :url

      t.timestamps
    end
  end
end
