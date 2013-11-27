class PersistentChannel < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user

  scope :users, where(follow_type: "User")


  after_create do

  end

  after_destroy do
  end
end
