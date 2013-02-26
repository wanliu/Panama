#encoding: utf-8

FactoryGirl.define do
  factory :style_item do |f|
  	sequence(:title) { |n| "title#{n}" }
	  sequence(:value) { |n| "value#{n}" }
	  sequence(:checked) { |n| n.remainder(2) == 0 }
    f.style_group :style_group
  end
end