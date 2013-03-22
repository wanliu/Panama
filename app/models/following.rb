#describe: 关注

class Following < ActiveRecord::Base
  attr_accessible :follow_id, :follow_type, :user_id

  belongs_to :user
  belongs_to :follow, :polymorphic => true

  def self.user(user_id, uid = nil)
    opts = {follow_id: user_id, follow_type: "User"}
    opts.merge!(user_id: uid) unless uid.nil?
    create(opts)
  end

  def self.shop(shop_id, uid = nil)
    opts = {follow_id: shop_id, follow_type: "Shop"}
    opts.merge!(user_id: uid) unless uid.nil?
    create(opts)
  end
end
