#encoding: utf-8
#describe: 关注
class Following < ActiveRecord::Base
  attr_accessible :follow_id, :follow_type, :user_id
  scope :shops, where(follow_type: "Shop")
  scope :users, where(follow_type: "User")

  belongs_to :user
  belongs_to :follow, :polymorphic => true

  validates :user_id, :presence => true
  validates_presence_of :user
  validates_presence_of :follow
  validate :valid_follow?

  def self.user(user_id, uid = nil)
    opts = {follow_id: user_id, follow_type: "User"}
    opts[:follow_id] = user_id.id if user_id.is_a?(User)
    opts.merge!(user_id: uid) unless uid.nil?
    create(opts)
  end

  def self.shop(shop_id, uid = nil)
    opts = {follow_id: shop_id, follow_type: "Shop"}
    opts[:follow_id] = shop_id.id if shop_id.is_a?(Shop)
    opts.merge!(user_id: uid) unless uid.nil?
    create(opts)
  end


  def valid_follow?
    if Following.exists?(["follow_id=? and follow_type=? and id<>? and user_id=?",
      follow_id, follow_type, id.to_s, user_id])
      errors.add(:follow_id, "已经是你关注对象!")
    end
  end

end
