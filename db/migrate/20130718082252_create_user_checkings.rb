class CreateUserCheckings < ActiveRecord::Migration
  def change
    create_table :user_checkings do |t|
    	t.references :user
    	t.references :service
    	t.string :industry_type
     	t.timestamps
    end
  end
end
