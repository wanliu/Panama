# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification do
    user_id 1
    mentionable_user_id 1
    mentionable_id 1
    mentionable_type "MyString"
  end
end
