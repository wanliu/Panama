# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shop_user, :class => 'ShopUser' do |f|
    f.shop :shop
    f.user :user
  end
end
