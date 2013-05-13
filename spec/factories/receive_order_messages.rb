# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :receive_order_message do
    order_transaction_id 1
    send_user_id 1
    message "MyText"
    state false
  end
end
