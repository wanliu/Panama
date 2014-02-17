# @author huxinghai, hysios
#
# @example how to use Notification
#
#   Notification.create!(
#      @user,
#      "#current_shop.name} 商店邀请你加入",
#      :url => notification_url(@user.login))
#
#   @user.notify( channel, content, options )
#   @user.notify("#current_shop.name} 商店邀请你加入",
#                :url => notification_url(@user.login),
#                 :persistent => true,
#                 :instant => true)
#
#
class Notification < ActiveRecord::Base

  scope :unreads, where(:read => false)
  scope :reads, where(:read => true)

  # @!method mentionable_user_id
  #   @deprecated 不要使用此方法
  #   @return [User] 发送给对方的用户
  attr_accessible :url, :body, :mentionable_user_id, :user_id, :targeable_type, :targeable_id, :targeable, :mentionable_user, :user

  attr_accessor :content, :additional, :channel

  belongs_to :user

  # @!method mentionable_user
  #   @deprecated 不要使用此方法
  #   @return [User] 发送给对方的用户

  belongs_to :mentionable_user, :class_name => "User", :foreign_key => "mentionable_user_id"
  belongs_to :targeable, :polymorphic => true
  # has_many :community_notifications, :dependent => :destroy

  validates_presence_of :user
  # validates_presence_of :mentionable_user

  after_create :expired_unreads

  before_save :generate_body

  def expired_unreads
    Notification.unreads.where({
      # mentionable_user_id: self.mentionable_user_id,
      targeable_type: self.targeable_type,
      targeable_id: self.targeable_id
    }).where('id <> ?', self.id).update_all(:read => true)
  end

  #
  # 发送数据到前端
  #
  # @deprecated 建议使用 push_to_client
  def realtime_push_to_client
    # count = Notification.unreads.where(mentionable_user_id: mentionable_user_id).count
    # CaramalClient.publish(mentionable_user.login, '/notification/#{mentionable_user.im_token}', {
    #   count: count,
    #   type: targeable_type,
    #   value: format_unread
    # })
  end

  def change_read
    self.update_attribute(:read, true)
  end

  def self.format_unreads(notifications = [])
    notifications.map do |notification|
      notification.format_unread
    end
  end

  def format_unread
    attra = self.as_json
    if self.targeable_type == "Activity"
      attra[:targeable] = {
        :id => targeable.id,
        :title => targeable.title,
        :img_url => targeable.photos.avatar
      }
    else
      attra[:targeable] = {
        :img_url => user.photos.avatar
      }
    end
    attra[:content] = content

    attra.delete("body")
    attra
  end

  def push_to_client(delay = 0)
    unless user.blank?
      data = {
        content: content,
        url: url,
        id: id,
      }.merge!(additional)

      target = unless targeable_type.nil?
                 { :type => targeable_type,
                   :id   => targeable_id }
               end

      data[:target] = target unless target.nil?


      puts "send #{data} to #{channel}"
      CaramalClient.publish(user.login, channel, data)
    end
  end

  def content
    @content ||= parse_body[0]
  end

  def additional
    @additional ||= parse_body[1]
  end

  #
  # 创建一个 Notification
  # @param  user [User, Fixnum] 一个用户实体或ID
  # @param  channel_or_object [String, ActiveRecord] 设定一频道名或一个对象
  # @param  content [String] 字符串内容
  # @param  options [Hash] 设置选项
  # @option options [String] :url 给通知指定一个 url
  # @option options [Object] :target 指定 targeable 对象
  # @option options [String] :persistent 持久化此通知，默认: true
  # @option options [String] :instant 实时知通目标用户，默认: true
  #
  # @return [Notification] 返回的 Notification 实体
  def self.create!(user, channel_or_object, content, opts)
    options = opts.symbolize_keys

    user_id = if user.is_a?(User)
                user.id
              elsif user.is_a?(Fixnum)
                user
              end

    channel = if channel_or_object.is_a?(String)
                channel_or_object
              elsif channel_or_object.is_a?(ActiveRecord::Base)
                klass_name = channel_or_object.class.name
                File.join('/',
                          klass_name.pluralize.underscore,
                          channel_or_object.to_param)
              elsif channel_or_object.is_a?(Class)
                channel_or_object.name
              else
                throw ArgumentError.new('channel_or_object type is invalid, must String or ActiveRecord')
              end

    attrs = {
      :user_id => user_id,
      :url     => options.delete(:url),
    }

    # options[:target] ||= channel_or_object

    if options[:target].is_a?(ActiveRecord::Base)
      attrs[:targeable_type] = options[:target].class.name
      attrs[:targeable_id]   = options[:target].id
      options.delete :target
    elsif options[:targeable_type]
      attrs[:targetable_type] = options.delete :targeable_type
      attrs[:targeable_id] = options.delete :targeable_id
    end

    notic       = new attrs
    persistent  = options.fetch(:persistent, true)
    instant     = options.fetch(:instant, true)

    options.delete(:persistent)
    options.delete(:instant)

    notic.content = content
    notic.additional = options
    notic.send(:generate_body)

    notic.channel = channel
    notic.save! if persistent

    notic.push_to_client if instant

    notic
  end

  def self.dual_notify(target, opts = {}, &block)
    options = opts.symbolize_keys
    channel = options.delete(:channel)
    content = options.delete(:content)

    target.notify(
      channel, content, options.merge(
        :persistent => false))

    if block_given? 
      yield(options) 
      channel = options.delete(:channel) if options.key?(:channel)
      content = options.delete(:content) if options.key?(:content)
    end

    target.notify(channel, content, options)
  end


  protected

  def generate_body
    value = if additional.is_a?(Hash)
              content + "\n\n" + additional.to_yaml
            else
              content
            end

    write_attribute(:body, value)
  end

  def parse_body
    begin
      value = read_attribute(:body)
      a,b = value.split("\n\n---")
      b = YAML.load(b)
    rescue
      a = value
      b = {}
    end
    if b.is_a?(Hash)
      [a, b]
    else
      [value, {}]
    end
  end
end
