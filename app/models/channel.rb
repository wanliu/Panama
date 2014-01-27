class Channel < ActiveRecord::Base
  attr_accessible :name#, :target_type
  belongs_to :target, polymorphic: true
end
