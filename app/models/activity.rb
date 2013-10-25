# coding:utf-8
class Activity < ActiveRecord::Base
  include Graphical::Display
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include MessageQueue::Activity

  attr_accessor :people_number

  scope :wait, lambda{ where(:status => statuses[:wait]) }
  scope :access, lambda{ where(:status => statuses[:access]) }
  scope :rejected, lambda{ where(:status => statuses[:rejected]) }

  attr_accessible :url, :shop_product_id, :start_time, :end_time, :price, :title,
                  :description, :like, :participate, :author_id, :status, :rejected_reason

  belongs_to :shop_product
  belongs_to :author, :class_name => "User"
  belongs_to :shop
  has_many :notifications, as: :targeable, class_name: "Notification", dependent: :destroy

  has_many :activity_rules, autosave: true
  has_many :comments, :as => :targeable
  has_many :activities_likes
  has_many :likes, :through => :activities_likes, :source => :user
  has_and_belongs_to_many :attachments, class_name: "Attachment"
  has_and_belongs_to_many :transactions, class_name: "OrderTransaction"

  has_many :activities_participates
  has_many :participates, :through => :activities_participates, :source => :user

  # validates_associated :product
  validates :price, :activity_price, :numericality => { :greater_than => 0 }, :presence => true
  validates :author, :title, :activity_price, :start_time, :end_time, :shop_product_id, :presence => true

  validate :validate_update_access?, :on => :update, :except => :update_like
  validate :validate_focus?

  define_graphical_attr :photos, :handler => :default_photo

  before_create :init_data

  before_validation(:on => :create) do
    valid_befor_init
  end

  before_destroy do
    validate_destroy_access?
  end

  def notice_author(sender, message)
    notifications.create({
      :user_id => sender.id,
      :mentionable_user_id => author.id,
      :url => "/activities/#{id}",
      :body => message
    })
  end

  def notice_followers
    followers = author.followers.where({:follow_type => User})
    followers.each do |follower|
      notifications.create({
        :user_id => author.id,
        :mentionable_user_id => follower.user_id,
        :url => "/activities/#{id}",
        :body => "有新活动发布"
      })
    end
  end

  def focus_price
    if activity_type == "focus"
      activity_rules.order(:value).find_by("value>#{participate}").type_val
    else
      0
    end
  end

  def init_data
    self.shop_id = author.shop.id
    self.like = like
    self.participate = participate
  end

  def valid_befor_init
    if self.activity_type == "focus"
      self.price = self.activity_rules.map{|a| a.dvalue}.min
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
    atts
  end

  def activity_price
    rule = activity_rules.find { |rule| rule.name == 'activity_price' }
    if rule.blank?
      ""
    else
      rule[rule.value_type]
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
        :id        => shop_product.category.id,
        :name      => shop_product.category.name
      },
      :participate_ids => participates.pluck("users.id"),
      :like_ids => likes.pluck("users.id")
    }.to_json
  end

  private
  def validate_focus?
    if activity_type == "focus"
      if activity_rules.length <= 0
        errors.add(:people_number, "不能为空！")
        errors.add(:activity_price, "不能为空！")
      end
    end
  end

  def validate_update_access?
    if Activity.statuses[:access] == Activity.find(self.id).status
      errors.add(:status, "已经审核了，不能修改！")
    end
  end
end
