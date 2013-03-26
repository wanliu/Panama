#describe: 圈子

class Circle < ActiveRecord::Base
  attr_accessible :name, :owner_id, :owner_type

  belongs :owner, :polymorphic => true
  validates :name, :presence => true

  has_many :circle_friends, :dependent => :destroy
end
