#encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :express, :class => DeliveryManner do
    code "express"
    name "快递运输"
    default_state true
  end

  factory :local_delivery , :class => DeliveryManner do
  	code "local_delivery"
  	name "本地送货"
  end
end
