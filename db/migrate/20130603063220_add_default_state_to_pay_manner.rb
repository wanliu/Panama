class AddDefaultStateToPayManner < ActiveRecord::Migration
  def change
    add_column :pay_manners, :default_state, :boolean, :default => false
  end
end
