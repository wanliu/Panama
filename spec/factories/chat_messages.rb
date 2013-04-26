# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :chat_message do
    send_user_id 1
    receive_user_id 1
    content "MyText"
  end
end
