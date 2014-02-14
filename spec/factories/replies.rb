# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reply do
    comment_id 1
    content "MyString"
    user_id 1
  end
end
