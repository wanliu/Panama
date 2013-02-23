#encoding: utf-8

FactoryGirl.define do
  factory :style_item do
  	sequence(:title) { |n| "title#{n}" }
	  sequence(:value) { |n| "value#{n}" }
	  sequence(:checked) { |n| n.remainder(3) == 0 }
    association :style_group, factory: :style_group
  end
end