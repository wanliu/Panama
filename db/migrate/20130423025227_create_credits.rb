class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.integer   :user_id
      t.integer   :bank_id
      t.string    :code

      t.timestamps
    end
  end
end
