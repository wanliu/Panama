class AddCodeToPayManner < ActiveRecord::Migration
  def change
    add_column :pay_manners, :code, :string
  end
end
