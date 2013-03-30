#descibe: 帖子类目
class TopicCategory < ActiveRecord::Base
  attr_accessible :name, :shop_id

  belongs_to :shop
  validates :name, presence: true
end
