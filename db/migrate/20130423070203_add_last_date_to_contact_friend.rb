class AddLastDateToContactFriend < ActiveRecord::Migration
  def change
    add_column :contact_friends, :last_contact_date, :datetime
  end
end
