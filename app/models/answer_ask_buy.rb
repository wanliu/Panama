class AnswerAskBuy < ActiveRecord::Base
  attr_accessible :amount, :ask_buy_id, :price, :shop_product_id, :total, :user_id, :status, :order_transaction_id

  belongs_to :ask_buy
  belongs_to :shop_product
  belongs_to :user
  belongs_to :order_transaction

  validates :user, :presence => true
  validates :shop_product, :presence => true
  validates :price,  :numericality => { :greater_than => 0 }, :presence => true
  validates :amount, :presence => true, 
            :numericality => { :greater_than => 0, :only_integer => true } 
  validates :total,  :numericality => { :greater_than => 0 }

  scope :hited, ->{ where(:status => 1)}
  scope :unhited, ->{ where(:status => 0)}

  after_create do 
  	ask_buy.user.notify("/answer_ask_buy",
								        "用户#{user.login} 对你求购的#{ ask_buy.title}  进行了报价",
								        :target => self,
								        :url => "/people/#{user.login}/ask_buy",
								        :avatar => user.avatar)
  end

  before_validation(:on => :create) do
    total_money
  end

  def add_order_id_and_status(order_transaction_id)
    update_attributes(:order_transaction_id => order_transaction_id, :status => true)
  end

  def total_money
    total = self.price * self.amount
  end

  def shop_product_name
  	shop_product.name
  end

  def shop_product_icon
    shop_product.photos.icon
  end

  def seller_shop
    self.user.shop
  end

  def buyer
    self.ask_buy.user
  end

  def hited_user
    AnswerAskBuy.hited.where(:ask_buy_id => ask_buy_id).first.user 
  end

  def unhited_users
    AnswerAskBuy.unhited.where(:ask_buy_id => ask_buy_id)
  end

  def notice_all_answered_user
    hited_user.notify("/shops/answer_ask_buy/success",
                      "#{ ask_buy.title}求购买家选择了你进行交易，请查看订单#{ order_transaction.number}",
                      :target => self,
                      :url => "/shops/#{ hited_user.shop.name}/admins/transactions/#{order_transaction.id}")
    
    unhited_users.each do |u| 
      u.notify("/shops/answer_ask_buy/failer",
              "很遗憾,#{ ask_buy.title}求购买家选择了商家 #{ order_transaction.seller.name} 进行交易,感谢您的参与...",
              :target => self,
              :url => "/shops/#{order_transaction.seller.name}")
    end
  end
end
