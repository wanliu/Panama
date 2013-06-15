class AddValueTypeToActivityRules < ActiveRecord::Migration
  def change
    add_column :activity_rules, :value_type, :string, :limit => 25
    add_column :activity_rules, :svalue, :string, :limit => 25
    add_column :activity_rules, :nvalue, :integer, :limit => 11
    add_column :activity_rules, :dvalue, :decimal, :precision => 10, :scale => 2
    add_column :activity_rules, :dtvalue, :datetime
  end
end
