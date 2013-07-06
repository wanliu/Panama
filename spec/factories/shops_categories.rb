# encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :shops_category, :class => ShopsCategory do |f|
    name "test_category"
    f.shop :shop
  end

  factory :yifu, :class => ShopsCategory  do | f |
    name "衣服test"
    f.shop :shop
  end

  factory :kuzhi, :class => ShopsCategory do | f |
    name "裤子"
    f.shop :shop
  end
end
