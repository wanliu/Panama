# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :direct_transaction do
    seller_id 1
    buyer_id 1
    total "9.99"
  end
end
