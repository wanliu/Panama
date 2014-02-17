# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction_state_detail do
    order_transaction_id 1
    state "MyString"
  end
end
