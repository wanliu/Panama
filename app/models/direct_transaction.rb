#encoding: utf-8
class DirectTransaction < ActiveRecord::Base
  attr_accessible :buyer_id, :seller_id

  acts_as_status :state, [:uncomplete, :complete]

  scope :uncomplete, where(:state => _get_state_val(:uncomplete))
  scope :completed, where(:state => _get_state_val(:complete))

  belongs_to :buyer, :class_name => "User"
  belongs_to :seller, :class_name => "Shop"
  belongs_to :operator, :class_name => "User"

  has_many :items, :class_name => "ProductItem", :as => :owner
  has_many :messages, :class_name => "ChatMessage", :as => :owner

  before_create :init_data

  after_create :notice_seller, :notice_new

  after_destroy :notice_destroy

  def init_data
    self.total = items.inject(0){|s, v|  s = s + (v.amount * v.price) }
    self.state = :uncomplete
  end

  def as_json(*args)
    attra = super *args
    attra["number"] =  number
    attra["buyer_login"] = buyer.login
    attra["items_count"] = items_count
    attra["unmessages_count"] = unmessages.count
    attra["state_title"] = I18n.t("direct_transaction_state.#{state.name}")
    attra
  end

  def notice_seller
    Notification.create!(
      :user_id => seller.user.id,
      :mentionable_user_id => buyer.id,
      :url => "/shops/#{seller.name}/admins/direct_transactions/#{id}",
      :body => "你有新的订单")
  end

  def notice_new
    faye_undispose({type: "new" ,values: as_json})
  end

  def notice_destroy
    if operator.nil?
      faye_undispose({type: "destroy" ,values: as_json})
    else
      faye_send("/DirectTransaction/#{id}/#{seller.im_token}/#{operator.im_token}/destroy", {})
    end
  end

  def items_count
    items.inject(0){|s, item| s = s + item.amount }
  end

  def unmessages
    messages.where(:receive_user_id => nil)
  end

  def faye_undispose(options)
    faye_send("/DirectTransaction/#{seller.im_token}/un_dispose", options)
  end

  def faye_send(url, options)
    FayeClient.send(url, options)
  end

  def number
    if id > 99999999
      "WLD#{ id }"
    else
      "WLD#{ '0' * (9 - id.to_s.length) }#{ id }"
    end
  end

end
