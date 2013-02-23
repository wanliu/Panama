# encoding: utf-8

FactoryGirl.define do
  factory :style_group do |f|
  	sequence(:name) { |n| "name#{n}" }
    f.product :product
  end
end