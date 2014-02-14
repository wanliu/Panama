# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :following do
    user_id 1
    follow_id 1
    follow_type "MyString"
  end
end
