class CreateActivityParticipates < ActiveRecord::Migration
  def change
    create_table :activities_participates do |t|
      t.integer :activity_id, :limit => 11
      t.integer :user_id, :limit => 11
    end
  end

end
