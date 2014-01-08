# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :answer_ask_buy do
    ask_buy_id 1
    shop_product_id 1
    amount 1
    price "9.99"
    user_id 1
    total "9.99"
  end
end
