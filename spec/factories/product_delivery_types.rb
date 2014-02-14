# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product_delivery_type do |f|
    f.product :product
    f.delivery_type :delivery_type
    delivery_price 9
  end
end
