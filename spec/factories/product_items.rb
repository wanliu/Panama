#encoding: utf-8

FactoryGirl.define do
  factory :product_item do |f|
    sequence(:amount, 5) { |n| n }
    sequence(:price, 5)  { |n| 1000 + n }
    sequence(:total, 5)  { |n| n * (1000 + n) }
    sequence(:title)     { |n| "title_#{n}" }
    f.cart :cart
    f.product :product
  end
end