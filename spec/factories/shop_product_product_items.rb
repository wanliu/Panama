# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shop_product_product_item, :class => 'ShopProductProductItems' do
    shop_product_id 1
    product_item_id 1
  end
end
