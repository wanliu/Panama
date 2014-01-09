class TemporaryChannel < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :targeable, :polymorphic => true
  belongs_to :user

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

    CaramalClient.create_temporary_channel(name, user.login, options) do |_token|
      puts _token
      self.update_attribute(:token, _token)
    end
  end

  after_destroy do
    CaramalClient.remove_temporary_channel(name, user.login)
  end

end
