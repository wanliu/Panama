class AddImTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :im_token, :string
  end
end
