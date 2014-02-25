#encoding: utf-8
#descirbe: 订单退货
#attributes
#  decription: 说明
#  total: 总金额
#  order_reason_id: 原因
#  order_transaction_id: 订单
#  buyer_id: 买家
#  seller_id: 卖家
#  operator_id: 操作员
#  refuse_reason: 拒绝理由
#  delivery_price: 退运费
#  delivery_code: 运单号
#  delivery_manner: 运输方式
class OrderRefund < ActiveRecord::Base
  include MessageQueue::OrderRefund

  scope :avaliable, where("state not in ('apply_refund', 'failure')")
  scope :completed, -> { where("state in ('complete', 'close')") }
  scope :uncomplete, -> { where("state not in ('complete', 'close')") }

  attr_accessible :decription, :order_reason_id, :delivery_price, :operator

  belongs_to :order_reason
  belongs_to :order, :foreign_key => "order_transaction_id", :class_name => "OrderTransaction"
  belongs_to :seller, class_name: "Shop"
  belongs_to :buyer, class_name: "User"
  belongs_to :operator, class_name: "User"

  has_many :items, class_name: "OrderRefundItem", dependent: :destroy
  has_many :state_details, class_name: "OrderRefundStateDetail", dependent: :destroy
  has_many :notifications, :as => :targeable, dependent: :destroy
  has_many :transfers, :as => :targeable, dependent: :destroy

  validates :order_reason, :presence => true
  validates :order, :presence => true
  validates :number, :presence => true, :uniqueness => true

  before_validation(:on => :create) do
    update_buyer_and_seller_and_operate
    generate_number
  end

  after_create :change_order_state, :notify_shop_refund, :create_state_detail

  validate :valid_shipped_order_state?, :valid_order_already_exists?, :on => :create

  validate :valid_destroy?, :on => :destroy
  validate :valid_base_info?

  after_destroy :notify_shop_destroy

  state_machine :state, :initial => :apply_refund do

    event :shipped_agree do
      transition [:apply_refund, :apply_expired, :apply_failure] => :waiting_delivery
    end

    event :unshipped_agree do
      transition [:apply_refund, :apply_expired, :apply_failure] => :complete
    end

    event :expired do
      transition :apply_refund => :apply_expired,
                 :waiting_delivery => :close,
                 :waiting_sign => :complete,
                 :apply_failure => :close
    end

    event :delivered do
      transition :waiting_delivery => :waiting_sign
    end

    event :sign do
      transition :waiting_sign => :complete
    end

    event :refuse do
      transition :apply_refund => :apply_failure
    end

    after_transition do |refund, transition|
      refund.create_state_detail
    end

    before_transition :apply_refund => :apply_failure do |refund, transition|
      refund.valid_refuse_reason?
      refund.rollback_order_state if refund.errors.messages.blank?
    end

    before_transition [:apply_failure, :apply_refund, :apply_expired] => :waiting_delivery do |refund, transition|      
      refund.valid_seller_money?
      refund.validate_shipped_order_state?
    end

    before_transition [:apply_failure, :apply_refund, :apply_expired] => :complete do |refund, transition|
      refund.valid_seller_money?
      refund.valid_unshipped_order_state?
      refund.create_returned_item
    end

    before_transition :waiting_sign => :complete do |refund, transition|
      refund.valid_seller_money?      
    end

    after_transition [:apply_failure, :apply_refund, :apply_expired] => :complete do |refund|
      refund.seller_refund_money
      refund.change_order_refund_state
    end

    after_transition :apply_failure => :waiting_delivery do |refund, transition|
      refund.change_order_refund_state
    end

    after_transition :waiting_sign => :complete do |refund, transition|
      refund.seller_refund_money
      refund.change_order_refund_state
      refund.generate_transfer
      refund.create_returned_item
    end

    after_transition :apply_refund => :apply_expired do |refund, transition|
      refund.apply_failure_notice
    end
  end

  def self.state_expired
    refunds = find(:all,
      :joins => "left join order_refund_state_details as detail
      on  detail.order_refund_id = order_refunds.id and
      detail.expired_state=true and
      detail.state=order_refunds.state",
      :conditions => ["detail.expired<=?", DateTime.now],
      :readonly => false)
    refunds.each{|ref| ref.fire_events!(:expired) }
    puts "=refund===start: #{DateTime.now}=====count: #{refunds.count}===="
    refunds
  end

  def generate_transfer
    items.each do |item|
      transfers.build(
        :status => :success,
        :amount => item.amount,        
        :shop_product => item.shop_product)      
    end
  end

  def change_order_state
    order.fire_events!(:returned)
    order.change_state_notify_seller(:returned)
    order.way_change_state_notify_buyer(:returned)
  end

  def current_state_detail
    state_details.find_by(:state => state)
  end

  def change_order_refund_state
    unless order.fire_state_event(:returned)
      errors.add(:state, "确认退货出错！")
    end
  end

  def create_returned_item
    items.each{|i| i.create_product_returned }
  end

  def notice_change_buyer(event_name)
    ename = event_name.to_s
    if %w(shipped_agree unshipped_agree refuse sign).include?(ename)
      Notification.dual_notify(buyer, 
        :channel => "/order_refunds/#{id}/change_state",
        :content => "退货单#{number} 状态变更为#{state_title}",
        :url => buyer_open_path,
        :target => self,
        :state => state_name,
        :event => "refresh_#{ename}",
        :state_title => state_title,
        :refund_id => id
      ) do |options|
        options[:channel] = "/order_refunds/change_state"
      end
    end
  end

  def notice_change_seller(event_name)
    ename = event_name.to_s
    if %w(delivered).include?(ename)
      target = operator.nil? ? seller : operator
      Notification.dual_notify(target,
        :channel => "/#{seller.im_token}/order_refunds/#{id}/change_state",
        :content => "退货单#{number} 状态变更为#{state_title}",
        :url => seller_open_path,
        :target => self,
        :event => "refresh_#{ename}",
        :state => state_name,
        :state_title => state_title,
        :refund_id => id
      ) do |options|
        options[:channel] = "/order_refunds/change_state"
      end
    end
  end

  def rollback_order_state
    order.fire_events!("rollback_#{order_state}")
  end

  def seller_fire_event(event)
    result = type_fire_events(%w(shipped_agree unshipped_agree refuse sign), event)
    notice_change_buyer(event) if result
    result      
  end

  def buyer_fire_event(event)
    result = type_fire_events(%w(delivered), event)    
    notice_change_seller(event) if result
    result
  end

  def update_buyer_and_seller_and_operate
    self.buyer_id = order.try(:buyer_id)
    self.seller_id = order.try(:seller_id)
    self.operator_id = order.operator.try(:operator_id)
    self.order_state = order.state
  end

  def create_state_detail
    state_details.update_all(:expired_state => false)
    state_details.create(:state => state)
  end

  def order_operator?
    order.current_operator.present?
  end

  def refund_product_ids
    items.pluck("product_id") 
  end

  def create_items(_items = [])
    _items = [_items] unless _items.is_a?(Array)
    _items.each do |item_id|
      product_item = order.items.find_by(:id => item_id)
      if product_item.present?
        items.create(
          :title => product_item.title,
          :amount => product_item.amount,
          :price => product_item.price,
          :shop_id => product_item.shop_id,
          :product_id => product_item.product_id)
      end
    end
    update_total
  end

  def update_total
    sum = items.inject(0){|sum, item| sum += item.total }
    self.update_attribute(:total, sum)
  end

  def stotal
    total + delivery_price
  end

  #退款
  def buyer_recharge           
    order.seller.user.payment(stotal, {
      :owner => self,
      :decription => "订单#{order.number}退货",
      :target => order.buyer,
      :pay_type => :account
    })
  end

  def valid_seller_money?
    order_money = order_state?(:complete) ? 0 : order.stotal
    if order.seller.user.valid_money?(stotal - order_money)
      errors.add(:seller, "余额不足,请充值！")
      false
    else
      true
    end
  end

  #卖家退款
  def seller_refund_money
    if valid_seller_money?
      active_order_money
      buyer_recharge
    end
  end

  def active_order_money
    order.seller_recharge unless order_state?(:complete)
  end

  def valid_destroy?
    unless state_name == :apply_refund
      errors.add(:state, "退货单删除失败!")
      false
    else
      true
    end
  end

  def valid_refuse_reason?
    if refuse_reason.blank?
      errors.add(:refuse_reason, "请填写拒绝理由!")
    end
  end

  def order_state?(_state)
    order_state == _state
  end

  def shipped_state?
    %w(waiting_sign complete).include?(order_state)
  end

  def unshipped_state?
    %w(delivery_failure waiting_delivery).include?(order_state)
  end

  def validate_shipped_order_state?
    unless shipped_state?
      errors.add(:state, "卖家还没有发货!")
    end
  end

  def valid_unshipped_order_state?
    unless unshipped_state?
      errors.add(:state, "卖家已经发送了!")
    end
  end

  def state_title
    I18n.t("refund_state.#{state}")
  end

  def generate_number
    _number = (OrderRefund.max_id + 1).to_s
    _number = "#{'0' * (9-_number.length)}#{_number}" if _number.length < 9
    self.number = _number
  end

  def self.max_id
    select("max(id) as id")[0].try(:id) || 0
  end


  private

  def valid_base_info?
    if changed.include?("delivery_price")
      unless %w(apply_refund apply_expired apply_failure).include?(state_name.to_s)
        errors.add(:delivery_price, "这状态不能修改运费！")
      else
        target = operator.nil? ? seller : operator
        Notification.dual_notify(target, 
          :channel => "/#{seller.im_token}/order_refunds/#{id}/change_info",
          :content => "退货单#{number}更改运费",
          :url => seller_open_path,
          :avatar => buyer.photos.icon,
          :refund_id => id,
          :target => self,
          :info => {
            :delivery_price => delivery_price,
            :stotal => stotal            
          }
        ) do |options|
          options[:channel] = "/order_refunds/change_info"
        end

        buyer.notify(
          "/order_refunds/#{id}/change_info",
          "退货单#{number}更改运费",
          :persistent => false,
          :refund_id => id,
          :info => {
            :delivery_price => delivery_price,
            :stotal => stotal  
          }
        )
      end
    end
  end

  def valid_shipped_order_state?
    unless order.order_refund_state?
      errors.add(:order_transaction_id, "订单属于不能退货状态！")
    end
  end

  def valid_order_already_exists?
    if order.refunds.count > 0
      errors.add(:order_transaction_id, '订单已经有退货了！')
    end
  end

  def notify_shop_destroy
    target = operator.nil? ? seller : operator
    Notification.dual_notify(target,
      :channel => "/#{seller.im_token}/order_refunds/destroy",
      :content => "退货单#{number}已经删除了!",
      :url => "/shops/#{seller.name}/admins/order_refunds",
      :avatar => buyer.photos.icon,
      :refund_id => id,
      :target => self
    ) do |options|
      options[:channel] = "/order_refunds/destroy"
    end
  end

  def notify_shop_refund
    target = operator.nil? ? seller : operator
    Notification.dual_notify(target,
      :channel => "/#{seller.im_token}/order_refunds/create",
      :content => "订单#{order.number}申请退货",
      :url => seller_open_path,
      :avatar => buyer.photos.icon,
      :refund_id => id,
      :target => self
    ) do |options|
      options[:channel] = "/order_refunds/create"
    end
  end

  def type_fire_events(states, event)
    if states.include?(event.to_s)
      fire_state_event(event)
    else
      errors.add(:state, "不能操作#{event}事件！")
      false
    end
  end

  def buyer_open_path
    "/people/#{buyer.login}/order_refunds#open/#{id}/refund"    
  end

  def seller_open_path
    "/shops/#{seller.name}/admins/order_refunds#open/#{id}/refund"
  end
end
