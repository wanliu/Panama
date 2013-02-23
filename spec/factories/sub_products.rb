#encoding: utf-8

FactoryGirl.define do
  factory :sub_product do
    sequence(:price, 1000) { |n| n }
    sequence(:quantity, 5) { |n| n }
    association :product, factory: :product
  end
end