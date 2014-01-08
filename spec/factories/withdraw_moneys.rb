# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :withdraw_money do
    money "9.99"
    bank_id 1
    user_id 1
    state false
    arrive_mode 1
  end
end
