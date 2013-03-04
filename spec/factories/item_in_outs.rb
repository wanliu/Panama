# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item_in_out do
    product_id 1
    product_item_id 1
    quantity "9.99"
    warehouse "MyString"
  end
end
