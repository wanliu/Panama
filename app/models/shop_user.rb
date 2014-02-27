
#encoding: utf-8
# describe: 商店雇员
class ShopUser < ActiveRecord::Base
  attr_accessible :user_id

  belongs_to :user
  belongs_to :shop

  has_many :shop_user_groups, :dependent => :destroy

  validates :user, :presence => true
  validate :valid_user_join_multi_shop?

  after_create :join_shop_temporary_channels
  after_destroy :remove_from_shop_temporary_channels

  def groups
    shop_user_groups.includes(:shop_group).map{|g| g.shop_group }
  end

  def jshop
    shop
  end
  
  def valid_user_join_multi_shop?
    if ShopUser.where("user_id=? and id<>?",
      user_id, id).count > 0
      errors.add(:user_id, "该用户已经加入其它商店!")
    end
  end

  protected

  # 将加入的雇员添加到商店订单的聊天中去
  def join_shop_temporary_channels
    all_order_channel_token.each do |order_ch_token|
      CaramalClient.add_remove_employee(order_ch_token, 'add', { employee: user.login })
    end
  end

  # 将开除的雇员从商店订单的聊天名单中除去
  def remove_from_shop_temporary_channels
    all_order_channel_token.each do |order_ch_token|
      CaramalClient.add_remove_employee(order_ch_token, 'remove', { employee: user.login })
    end
  end

  def all_order_channel_token
    shop.transactions.to_a
        .concat(shop.direct_transactions)
        .map(&:temporary_channel)
        .map(&:token)
        .compact
  end
end
