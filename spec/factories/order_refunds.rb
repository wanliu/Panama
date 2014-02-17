# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order_refund do
    order_reason_id 1
    money "9.99"
    decription "MyText"
    order_transaction_id 1
  end
end
