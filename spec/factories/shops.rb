#encoding: utf-8
FactoryGirl.define do
	factory :shop do |f|
		sequence(:name){ |n| "测试商店#{n}" }
    association :user, factory: :user
	end
end