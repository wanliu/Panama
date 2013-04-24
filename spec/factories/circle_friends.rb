# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :circle_friend do
    name "MyString"
    owner_id 1
    owner_type "MyString"
    following_id 1
  end
end
