# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sale_group, :class => ShopGroup do | f |
    f.shop :shop
    name "sale"
  end

  factory :inventor_group, :class => ShopGroup do |f|
    f.shop :shop
    name "inventory"
  end

  factory :admin_group, :class => ShopGroup do |f|
    f.shop :shop
    name "admin"
  end

end
