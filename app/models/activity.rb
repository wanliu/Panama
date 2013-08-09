# coding:utf-8
class Activity < ActiveRecord::Base
  include Graphical::Display
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include MessageQueue::Activity

  attr_accessible :url, :shop_product_id, :start_time, :end_time, :price, :title,
                  :description, :like, :participate, :author_id, :status, :rejected_reason

  belongs_to :shop_product
  belongs_to :author, :class_name => "User"
  belongs_to :shop

  has_many :activity_rules, autosave: true

  has_many :comments, :as => :targeable
  has_many :activities_likes
  has_many :likes, :through => :activities_likes, :source => :user
  has_and_belongs_to_many :attachments, class_name: "Attachment"

  has_many :activities_participates
  has_many :participates, :through => :activities_participates, :source => :user

  # validates_associated :product
  validates_presence_of :author

  define_graphical_attr :photos, :handler => :default_photo

  before_create :init_data

  after_create :notice_user, :notice_new_activity

  def notice_user
    Notification.create!(
      :user_id => author.id,
      :mentionable_user_id => User.last.id,
      :url => "/activities/#{id}",
      :body => "有新活动发布")
  end

  def init_data
    self.shop_id = author.shop.id
  end

  def default_photo
    attachments.first ? attachments.first.file : Attachment.new.file
  end

  validates :price,:start_time,:end_time,:shop_product_id,:presence => true

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

  def send_checked_mail
    UserMailer.delay.send_activity_checked_notify(author.email, author, url)
  end

  def send_rejected_mail
    UserMailer.delay.send_activity_rejected_notify(author.email, author, rejected_reason, url)
  end

  private
  def notice_new_activity
   realtime_dispose({type: "new" ,values: as_json})
  end

  def notice_activity_dispose
    realtime_dispose({type: "dispose" ,values: as_json})
  end

  def realtime_dispose(data = {})
    faye_send("/Activity/35/un_dispose", data)
  end

  def faye_send(channel, options)
    FayeClient.send(channel, options)
  end
end
