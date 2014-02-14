# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :products_property_item, :class => 'ProductsPropertyItems' do
    product_id 1
    property_item_id 1
  end
end
