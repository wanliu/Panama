# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shop_product_refund_item, :class => 'ShopProductRefundItems' do
    shop_product_id 1
    order_refund_item_id 1
  end
end
