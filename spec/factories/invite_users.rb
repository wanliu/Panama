# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invite_user do
    body "MyText"
    user_id 1
    send_user_id 1
    targeable_type "MyString"
    targeable_id 1
    read false
  end
end
