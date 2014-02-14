# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order_refund_item do
    order_refund_id 1
    product_item_id 1
  end
end
