#encoding: utf-8

FactoryGirl.define do

	factory :root_category, :class => Category do | f |
		name "root_test"
		association :shop, factory: :shop
	end

	factory :yifu, :class => Category do | f |
		name "衣服test"
		association :shop, factory: :shop
	end

	factory :kuzhi, :class => Category do | f |
		name "裤子"
		association :shop, factory: :shop
	end
end