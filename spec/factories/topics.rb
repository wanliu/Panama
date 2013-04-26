# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :topic do
    user_id 1
    owner_id 1
    owner_type "MyString"
    content "MyString"
  end
end
