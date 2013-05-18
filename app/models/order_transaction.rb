#encoding: utf-8
#describe: 订单交易
#attributes:
#  operator_state: 订单处理状态(true: 有人处理, false: 没有人处理)
#  operator_id: 当前操作员
#  buyer_id: 买家(用户)
#  seller_id: 卖家(商店)
#  state: 交易状态
#  total: 总金额
#  address: 送货地址
#  items_count: 商品总项
class OrderTransaction < ActiveRecord::Base
  include Realtime::Transaction

  attr_accessible :buyer_id, :items_count, :seller_id, :state, :total, :address
  # attr_accessor :total

  has_one :address,
          foreign_key: 'transaction_id'

  belongs_to :seller, class_name: "Shop"
  belongs_to :buyer,
             class_name: "User"
  belongs_to :operator, class_name: "TransactionOperator"

  has_many :operators, class_name: "TransactionOperator"

  has_many  :items,
            class_name: "ProductItem",
            foreign_key: 'transaction_id',
            autosave: true

  has_many :receive_order_messages
  has_many :chat_messages, :as => :owner

  validates :state, :presence => true
  validates :items_count, :numericality => true
  validates :total, :numericality => true, :allow_nil => true

  validates_presence_of :buyer
  validates_presence_of :seller_id
  validates_associated :address
  # validates_presence_of :address
  validate :valid_address?

  accepts_nested_attributes_for :address
  # validates_presence_of :address

  after_create :notice_user

  def notice_user
    Notification.create!(
      :user_id => seller.user.id,
      :mentionable_user_id => buyer.id,
      :url => "/shops/#{seller.name}/admins/transactions/#{id}",
      :body => "你有新的订单")
    FayeClient.send("/transaction/new/#{seller.id}/un_dispose", as_json)
  end

  state_machine :initial => :order do

    event :buy do
      transition [:order] => :waiting_paid
    end

    event :back do
      transition :waiting_paid     => :order,
                 :waiting_delivery => :waiting_paid,
                 :waiting_sign     => :waiting_delivery
    end

    # 等待发货
    event :paid do
      transition [:waiting_paid] => :waiting_delivery
    end

    # 发货
    event :delivered do
      transition :waiting_delivery => :waiting_sign
    end

    # 签收
    event :sign do
      transition [:waiting_sign] => :complete
    end

    after_transition :order            => :waiting_paid,
                     :waiting_paid     => :waiting_delivery do |order, transition|
      token = order.current_operator.try(:im_token)
      FayeClient.send("/events/#{token}/transaction-#{order.id}-seller",
                      :name => transition.to_name) unless token.blank?
      true
    end

    ## only for development
    if Rails.env.development?
      after_transition :waiting_paid      => :order,
                       :waiting_delivery  => :waiting_paid,
                       :waiting_sign      => :waiting_delivery do |order, transition|
        token = order.current_operator.try(:im_token)
        FayeClient.send("/events/#{token}/transaction-#{order.id}-seller",
                        :name => transition.to_name,
                        :event => :back) unless token.blank?
      end
    end

    after_transition :waiting_delivery => :waiting_sign do |order, transition|
      token = order.buyer.try(:im_token)
      FayeClient.send("/events/#{token}/transaction-#{order.id}-buyer",
                      :name => transition.to_name,
                      :event => :delivered) unless token.blank?

    end
  end

  def current_operator
    operator.try(:operator)
  end

  def operator_connect_state
    state = current_operator.nil? || !current_operator.connect_state ? false : true
    self.update_attribute(:operator_state, state)
  end

  def operator_create(toperator_id)
    unless operator.try(:id) == toperator_id
      _operator = operators.create(operator_id: toperator_id)
      self.update_attribute(:operator_id, _operator.id)
    end
    FayeClient.send("/transaction/#{seller.id}/dispose", as_json)
    operator_connect_state
  end

  #买家发送信息
  def message_create(options)
    #是否有销售组成员在线
    unless seller.seller_group_employees.any?{|u| u.connect_state }

    end
    operator_connect_state
    if operator_state
      options[:receive_user] = current_operator
    else
      options.delete(:receive_user)
    end
    chat_messages.create(options)
  end

  def unmessages
    chat_messages.where("receive_user_id is null")
  end

  #获取信息
  def messages
    chat_messages
  end

  def build_items(item_ar)
    item_ar.each { |item| items.build(item) }
    self
  end

  def update_total_count
    self.items_count = items.inject(0) { |s, item| s + item.amount }
    self.total = items.inject(0) { |s, item| s + item.total }
  end

  def as_json(*args)
    attra = super *args
    attra["buyer_login"] = buyer.login
    attra["address"] = address.try(:location)
    attra["unmessages_count"] = unmessages.count
    attra
  end

  private
  def valid_address?
    puts "state: #{state_name}"
    unless state_name == :order
      errors.add(:address, "地址不存在！") if address.nil?
    end
  end
end
