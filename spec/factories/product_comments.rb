# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product_comment do
    product_item 1
    shop_id 1
    user_id 1
    comment "MyText"
    star_product 1
    star_service 1
    star_logistics 1
  end
end
