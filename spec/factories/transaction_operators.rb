# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction_operator do
    order_transaction_id 1
    operator_id 1
  end
end
