# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recharge do
    user_id 1
    money "9.99"
    payer 1
    state false
  end
end
