# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order_refund_state_detail do
    order_refund_id 1
    state "MyString"
    expired "2013-05-29 11:28:30"
    expired_state false
  end
end
