#encoding: utf-8

FactoryGirl.define do

	factory :root_category, :class => Category do
		name "root_test"
		association :shop
	end

	factory :category do
		name "衣服test"
	end
end