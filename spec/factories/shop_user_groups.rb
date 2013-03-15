# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shop_user_group, :class => ShopUserGroup do | f |
    f.shop_user :shop_user
    f.shop_group :shop_group
  end
end
