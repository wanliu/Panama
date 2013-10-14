class CreateCircleSettings < ActiveRecord::Migration
	def change
		create_table :circle_settings, :force => true do |t|
			t.boolean :limit_city, :default => false 
			t.boolean :limit_join, :default => false
			t.timestamps
		end
	end
end
