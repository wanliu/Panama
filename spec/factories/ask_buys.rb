# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ask_buy do
    product_id 1
    title "MyString"
    price "9.99"
    amount 1.5
    describe "MyText"
    status 1
  end
end
