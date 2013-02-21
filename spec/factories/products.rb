#encoding: utf-8

FactoryGirl.define do
    factory :product do
        sequence(:name){ |n| "测试产品#{n}" }
        price 1.5
        summary "某某公司"
        description "描述某某公司"
    end
end