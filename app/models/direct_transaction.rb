#encoding: utf-8
class DirectTransaction < ActiveRecord::Base
  attr_accessible :buyer_id, :seller_id, :operator

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

  after_create :notice_seller

  after_destroy :notice_destroy

  after_update :notice_change_state

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
    attra["state_name"] = state.name
    attra["created_at"] = created_at.strftime("%Y-%m-%d %H:%M:%S")
    attra
  end

  def chat_notify(send_user, receive_user, content)
    if receive_user.present?
      url = if receive_user == buyer
        "/people/#{receive_user.login}/direct_transactions/#{id}"
      else
        "/shops/#{seller.name}/admins/direct_transactions/#{id}"
      end

      receive_user.notify(
        "/#{seller.im_token}/direct_transactions/#{id}/chat",
        content,
        :direct_id => id,
        :send_user => {
          :login => send_user.login,
          :id => send_user.id,
          :photos => send_user.photos.attributes
        },
        :created_at => DateTime.now,
        :avatar => send_user.photos.icon,
        :url => url
      )
    else
      seller.notify(
        "/#{seller.im_token}/direct_transactions/#{id}/chat",
        content,
        :direct_id => id,
        :avatar => send_user.photos.icon,
        :url => "/shops/#{seller.name}/admins/direct_transactions/#{id}"
      )
    end
  end

  def state_title
    I18n.t("direct_transaction_state.#{state.name}")
  end

  def update_operator(user)
    results = if operator.nil? && seller.is_employees?(user)
      update_attributes(:operator => user)
    end
    seller.notify(
      "/#{seller.im_token}/direct_transactions/dispose",
      "直接交易订单#{number}被#{user.login}处理了",
      :url => "/shops/#{seller.name}/admins/direct_transactions/#{id}",
      :avatar => user.photos.icon,
      :target => self,
      :direct_id => id,
      :exclude => user
    ) if results
    results
  end

  def notice_seller
    seller.notify(
      "/#{seller.im_token}/direct_transactions/create",
      "你有新的直接交易订单#{number}",
      :url => "/shops/#{seller.name}/admins/direct_transactions/#{id}",
      :avatar => buyer.photos.icon,
      :target => self,
      :direct_id => id
    )
  end

  def notice_change_state
    if changed.include?("state")
      target = operator.nil? ? seller : operator
      target.notify(
        "/#{seller.im_token}/direct_transactions/#{id}/change_state",
        "直接交易订单#{number}状态变更#{state_title}",
        :url => "/shops/#{seller.name}/admins/direct_transactions/#{id}",
        :avatar => buyer.photos.icon,
        :target => self,
        :state => state.name,
        :state_title => state_title,
        :direct_id => id
      )
    end
  end

  def notice_destroy
    target = operator.nil? ? seller : operator
    target.notify(
      "/#{seller.im_token}/direct_transactions/destroy",
      "直接交易订单#{number}被删除",
      :avatar => buyer.photos.icon,
      :direct_id => id,
      :persistent => false
    )
  end

  def items_count
    items.inject(0){|s, item| s = s + item.amount }
  end

  def unmessages
    messages.where(:receive_user_id => nil)
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
