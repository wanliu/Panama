# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order_transaction do
  end

  factory :transaction, class: OrderTransaction do |f|
    state "order"
    f.buyer :buyer
    f.seller :seller
    items_count 5
    total 10
  end
end
