#encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ems, :class => DeliveryType do
  	name "ems"
  	description "国企邮局"
  end

  factory :shentong, :class => DeliveryType do
  	name "申通"
  	description "速度一般般"
  end
end
