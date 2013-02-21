#encoding: utf-8

FactoryGirl.define do

	factory :root_category, :class => Category do | f |
		name "root_test"
		f.shop :shop
	end

	factory :category do
		name "衣服test"
	end
end