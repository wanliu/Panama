#encoding: utf-8

FactoryGirl.define do
    factory :product do | f |
        name "测试产品"
        price 1.5
        summary "某某公司"
        description "描述某某公司"
        association :shop, factory: :shop
        association :category, factory: :root_category
    end
end