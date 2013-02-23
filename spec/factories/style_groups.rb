# encoding: utf-8

FactoryGirl.define do
  factory :style_group do
  	sequence(:name) { |n| "name#{n}" }
    association :product, factory: :product
  end
end