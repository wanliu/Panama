# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :inventory_cach, :class => 'InventoryCache' do
    product_id 1
    styles "MyString"
    count "9.99"
    warhouse "MyString"
  end
end
