#describe: 圈子

class Circle < ActiveRecord::Base
  attr_accessible :name, :owner_id, :owner_type

  belongs_to :owner, :polymorphic => true
  validates :name, :presence => true

  has_many :friends, dependent: :destroy, class_name: "CircleFriends"

  def friend_count
  	friends.count
  end
end
