# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    title "MyString"
    content "MyString"
    user_id 1
    product_id 1
  end
end
