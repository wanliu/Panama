class TemporaryChannel < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :targeable, :polymorphic => true
  belongs_to :user

  after_create do
    CaramalClient.create_temporary_channel(name, user.login) do |_token|
      self.update_attribute(:token, _token)
    end
  end

  after_destroy do
    CaramalClient.remove_temporary_channel(name, user.login)
  end

end
