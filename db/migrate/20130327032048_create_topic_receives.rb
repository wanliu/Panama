class CreateTopicReceives < ActiveRecord::Migration
  def change
    create_table :topic_receives do |t|
      t.integer :topic_id
      t.integer :receive_id
      t.string :receive_type

      t.timestamps
    end
  end
end
