# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dialogue do
    user_id 1
    friend_id 1
    token "MyString"
  end
end
