#encoding: utf-8
FactoryGirl.define do
	factory :shop do
		sequence(:name){ |n| "测试商店#{n}"}
	end
end