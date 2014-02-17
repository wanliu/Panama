#describe: 聊天对话框
class Dialogue < ActiveRecord::Base
  attr_accessible :friend_id, :user_id

  belongs_to :user
  belongs_to :friend, class_name: "User"

  validates :friend, :presence => true
  validates :user, :presence => true

  before_create :generate_token

  def self.display(token, user_id = nil)
    find_by(:user_id => user_id, :token => token)
  end

  def self.generate(friend_id, user_id = nil)
    option = {:friend_id => friend_id, :user_id => user_id}
    dialogue = find_by(option)
    dialogue.nil? ? create(option) : dialogue
  end

  def generate_token
    self.token = SecureRandom.hex
  end
end
