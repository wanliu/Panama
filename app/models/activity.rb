# coding:utf-8
class Activity < ActiveRecord::Base
  include Graphical::Display
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Tire::Model::UpdateByQuery
  include MessageQueue::Activity

  attr_accessor :people_number, :activity_price, :attachment_ids

  scope :wait, lambda{ where(:status => statuses[:wait]) }
  scope :access, lambda{ where(:status => statuses[:access]) }
  scope :rejected, lambda{ where(:status => statuses[:rejected]) }

  attr_accessible :url, :shop_product_id, :start_time, :end_time, :price, :title,
                  :description, :like, :participate, :author_id, :status, :rejected_reason

  belongs_to :shop_product
  belongs_to :author, :class_name => "User"
  belongs_to :shop
  has_many :notifications, as: :targeable, class_name: "Notification", dependent: :destroy

  has_many :activity_rules, autosave: true, dependent: :destroy
  has_many :comments, :as => :targeable, dependent: :destroy
  has_many :activities_likes, dependent: :destroy
  has_many :likes, :through => :activities_likes, :source => :user
  has_and_belongs_to_many :attachments, class_name: "Attachment"
  has_and_belongs_to_many :transactions, class_name: "OrderTransaction"

  has_many :activities_participates, dependent: :destroy
  has_many :participates, :through => :activities_participates, :source => :user
  has_one :temporary_channel, :as => :targeable
  # validates_associated :product
  validates :price, :numericality => { :greater_than => 0, :less_than => 9999999 }, :presence => true
  validates :author, :title, :start_time, :end_time, :shop_product_id, :presence => true

  validate :validate_update_access?, :on => :update, :except => :update_like
  validate :validate_focus?, :validate_auction?

  define_graphical_attr :photos, :handler => :default_photo

  before_create :init_data

  before_validation(:on => :create) do
    valid_befor_init
  end

  before_destroy do
    validate_destroy_access?
  end

  after_create :create_the_temporary_channel

  def notify_url
    "/activities/#{id}"
  end

  def notice_author
    author.notify("/activities/add",
                  "您发布的活动#{ title}已经通过审核,定于#{ start_time}正式开始",
                  {:url => notify_url,
                   :avatar => photos.avatar,
                   :target => self })
  end

  def notice_followers
    unless shop.followers.blank?
      (shop.followers - [ author ]).each do |follower|
        follower.user.notify('/activities/add',
                             "您关注的商家 #{shop.name} 发布新活动 #{title},定于#{ start_time}正式开始,敬请期待",
                             {:target => self,
                              :url => notify_url,
                              :avatar => photos.avatar } )
      end
    end
  end

  def activity_detail_desription
    "<h4>发布活动: <a href='/activities/#{ id}'>#{ title} </a></h4><p>活动简介：#{ description || '暂无描述'}
    原价： ￥ <span class='normal-price'>#{ price.to_f }  </span> &nbsp;  最低价： ￥<span class='red-price'> #{ activity_price.to_f }</span> </p>"
  end

  def draw_topic_in_yourself_circle
    shop.circles.each do |c|
      catetory_id = c.categories.first && c.categories.first.id
      topic = c.topics.create(
        :content => activity_detail_desription,
        :user => shop.user,
        :category_id => catetory_id )
      topic.attachments <<  self.attachments.limit(2)  if self.attachments.length > 0
    end
  end

  def init_data
    self.title = self.title.to_s + I18n.t("activity.type.#{self.activity_type}")
    self.shop_id = author.shop.id
    self.like = like
    self.participate = participate
  end

  def valid_befor_init
    if foucs_type?
      self.price = activity_rules.map{|r| r.type_val}.min
    end
  end

  def default_photo
    attachments.first ? attachments.first.file : Attachment.new.file
  end

  def like
    likes.size
  end

  def participate
    participates.size
  end

  def as_json(options = nil)
    atts = super(:include => {
          :author   => {
            :include => :photos },
          :comments => {
            :include => {
              :user => {
                :include => :photos }}}})
    atts["url"] = photos.default
    atts["shop_name"] = shop.name
    atts
  end

  def activity_price
    case activity_type
    when "auction"
      auction_price
    when "focus"
      current_focus_price
    else
      0
    end
  end

  def self.statuses
    { :wait => 0, :access => 1, :rejected => 2 }
  end

  def user_liked?(user)
    user_id = user
    user_id = user.id if user.kind_of?(User)
    likes.exists?(["users.id=?", user_id])
  end

  def user_participated?(user)
    user_id = user
    user_id = user.id if user.kind_of?(User)
    participates.exists?(["users.id=?", user_id])
  end

  def start_sale?
    if Activity.statuses[:access] == status
      if start_time < DateTime.now
        return true
      end
    end
    return false
  end

  def foucs_type?
    activity_type == "focus"
  end

  def send_checked_mail
    UserMailer.delay.send_activity_checked_notify(author.email, author, url)
  end

  def send_rejected_mail
    UserMailer.delay.send_activity_rejected_notify(author.email, author, rejected_reason, url)
  end

  def validate_destroy_access?
    if Activity.statuses[:access] == self.status
      errors.add(:status, "已经审核了，不能删除！")
      return false
    end
  end

  def valid_expired?
    if end_time < DateTime.now
      errors.add(:end_time, "活动已经过期!")
      false
    else
      true
    end
  end

  def update_like
    self.update_attribute(:like, like)
  end

  def update_participate
    self.update_attribute(:participate, participate)
  end

  def to_indexed_json
    {
      :title   => title,
      :activity_type => activity_type,
      :shop_product_id  => shop_product_id,
      :description    => description,
      :price          => price,
      :start_time     => start_time.strftime("%Y-%m-%d %H:%M:%S"),
      :end_time       => end_time.strftime("%Y-%m-%d %H:%M:%S"),
      :participate    => participate,
      :status      => status,
      :like        => like,
      :created_at  => created_at,
      :updated_at  => updated_at,
      :author => {
        :id        =>  author.id,
        :login     =>  author.login,
        :photos    => {
          :icon      => author.photos.icon,
          :header    => author.photos.header,
          :avatar    => author.photos.avatar
        }
      },
      :shop        => {
        :id        => shop.id,
        :name      => shop.name,
        :photos    => {
          :icon      => shop.photos.icon,
          :header    => shop.photos.header,
          :avatar    => shop.photos.avatar
        }
      },
      :photos      => {
        :icon         => photos.icon,
        :header       => photos.header,
        :avatar       => photos.avatar
      },
      :category    => {
        :id        => shop_product.try(:category).try(:id),
        :name      => shop_product.try(:category).try(:name)
      },
      :participate_ids => participates.pluck("users.id"),
      :like_ids => likes.pluck("users.id"),
      :product => {
        :id => shop_product.try(:product_id),
        :name => shop_product.try(:name),
        :properties => shop_product.try(:properties_json)
      },
      :temporary_channel => {
        :name => temporary_channel.try(:name),
        :token => temporary_channel.try(:token)
      }
    }.to_json
  end

  def auction_type?
    activity_type == "auction"
  end

  def focus_price
    _focus_price(participate + 1)
  end

  def focus_spread
    activity_price - focus_price
  end

  private
  def validate_focus?
    if foucs_type?
      if activity_rules.length <= 0
        errors.add(:people_number, "不能为空！")
        errors.add(:activity_price, "不能为空！")
      end
    end
  end

  def validate_auction?
    if auction_type?
      if activity_rules.length <= 0
        errors.add(:activity_price, "不能为空！")
      end
    end
  end

  def current_focus_price
    _focus_price(participate)
  end

  def _focus_price(value)
    if foucs_type?
      activity_rules.focus_price(value)
    else
      0
    end
  end

  def auction_price
    if auction_type?
      activity_rules[0].type_val
    else
      0
    end
  end

  def validate_update_access?
    if Activity.statuses[:access] == Activity.find(self.id).status
      errors.add(:status, "已经审核了，不能修改！")
    end
  end

  def create_the_temporary_channel
    name = self.class.to_s << "_" << title
    self.create_temporary_channel(targeable_type: "Activity", user_id: shop.owner.id, name: name)
  end
end
