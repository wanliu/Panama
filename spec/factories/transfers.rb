# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transfer do
    targeable_type "MyString"
    targeable_id 1
    amount 1
    status 1
    shop_product 1
  end
end
