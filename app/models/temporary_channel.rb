class TemporaryChannel < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :targeable, :polymorphic => true
  belongs_to :user
  has_one :channel, as: :target

  def channel_id
    if channel.blank?
      create_channel(name: name)
      channel.id
    else
      channel.id
    end
  end

  before_create do
    create_channel(name: name)
  end

  after_create do
    options = {}
    if "OrderTransaction" == self.targeable_type
      options[:members] = [self.targeable.buyer.login]
      options[:mode] = "onlyMember"
    elsif "DirectTransaction" == self.targeable_type
      options[:members] = [self.targeable.buyer.login]
      options[:mode] = "onlyMember"
    elsif "Activity" == self.targeable_type
      options[:mode] = "any"
    end

    channel_id = channel_id
    CaramalClient.create_temporary_channel(channel_id, user.login, options) do |_token|
      puts _token
      self.update_attribute(:token, _token)
    end
  end

  after_destroy do
    channel_id = channel_id
    CaramalClient.remove_temporary_channel(channel_id, user.login)
  end

end
