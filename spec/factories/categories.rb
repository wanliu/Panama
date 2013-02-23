#encoding: utf-8

FactoryGirl.define do

	factory :root_category, :class => Category do | f |
		name "root_test"
		f.shop :shop
	end

	factory :category do |f|
		name "test_category"
		f.shop :shop
	end

	factory :yifu, :class => Category do | f |
		name "衣服test"
		f.shop :shop
	end

	factory :kuzhi, :class => Category do | f |
		name "裤子"
		f.shop :shop
	end
end