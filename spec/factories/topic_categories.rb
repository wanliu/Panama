#encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :topic_category do |f|
    name "活动"
    f.shop :shop
  end

end
