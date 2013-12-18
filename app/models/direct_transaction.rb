#encoding: utf-8
class DirectTransaction < ActiveRecord::Base
  attr_accessible :buyer_id, :seller_id

  acts_as_status :state, [:uncomplete, :complete]

  scope :uncomplete, where(:state => _get_state_val(:uncomplete))
  scope :completed, where(:state => _get_state_val(:complete))

  belongs_to :buyer, :class_name => "User"
  belongs_to :seller, :class_name => "Shop"
  belongs_to :operator, :class_name => "User"

  has_many :items, :class_name => "ProductItem", :as => :owner, :dependent => :destroy
  has_many :messages, :class_name => "ChatMessage", :as => :owner, :dependent => :destroy
  has_many :notifications, :as => :targeable, dependent: :destroy

  validates :buyer, :presence => true
  validates :seller, :presence => true
  validates :number, :presence => true, :uniqueness => true

  before_validation(:on => :create) do
    generate_number
  end

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
    attra["buyer_login"] = buyer.try(:login)
    attra["items_count"] = items_count
    attra["unmessages_count"] = unmessages.count
    attra["state_title"] = state_title
    attra["created_at"] = created_at.strftime("%Y-%m-%d %H:%M:%S")
    attra
  end

  def chat_notify(send_user, receive_user, content)
    _content = "#{send_user.login}说: #{content}"
    if receive_user.present?
      url, channel = if receive_user == buyer
        ["/people/#{receive_user.login}/direct_transactions/#{id}",
        "/direct_transactions/chat"]
      else
        ["/shops/#{seller.name}/admins/direct_transactions/#{id}",
        "/#{seller.im_token}/direct_transactions/#{receive_user.login}/chat"]
      end
      receive_user.notify(
        channel,
        _content,
        :order_id => id,
        :avatar => send_user.photos.icon,
        :url => url
      )
    else
      seller.notify(
        "/#{seller.im_token}/direct_transactions/chat",
        _content,
        :order_id => id,
        :avatar => send_user.photos.icon,
        :url => "/shops/#{seller.name}/admins/direct_transactions/#{id}"
      )
    end
  end

  def state_title
    I18n.t("direct_transaction_state.#{state.name}")
  end

  def notice_url(current_user)
    url = if self.buyer == current_user
      "/people/#{current_user.login}/transactions#direct#{self.id}"
    else
      "/shops/#{self.seller.name}/admins/pending#direct#{self.id}"
    end
  end

  def notice_seller
    notifications.create!(
      :user_id => buyer.id,
      :mentionable_user_id => seller.user_id,
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
    # FayeClient.send(url, options)
    CaramalClient.publish(seller.user.login, url, options)
  end

  def generate_number
    _number = (DirectTransaction.max_id + 1).to_s
    _number = "D#{'0' * (9-_number.length)}#{_number}" if _number.length < 9
    self.number = _number
  end

  def self.max_id
    select("max(id) as id")[0].try(:id) || 0
  end

end
