#encoding: utf-8

FactoryGirl.define do
  factory :sub_product do |f|
    sequence(:price, 1000) { |n| n }
    sequence(:quantity, 5) { |n| n }
    f.product :product
  end
end