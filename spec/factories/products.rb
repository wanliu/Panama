#encoding: utf-8

FactoryGirl.define do

  factory :product do | f |
    sequence(:name){ |n| "测试商品#{n}" }
    price 1.5
    summary "某某公司"
    description "描述某某公司"
    f.shop :shop
    f.category :category
    f.shops_category :shops_category
  end
end