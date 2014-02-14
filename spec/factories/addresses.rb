#encoding: utf-8

FactoryGirl.define do
  factory :address do |f|
    country '中国CHINA'
    sequence(:road) { |n| "the_#{n}th_road" }
    sequence(:zip_code, 421800) { |n| "#{n}" }
    contact_name "李四"
    contact_phone "15844545466"
    f.user :user
    f.province :province
    f.city :city
    f.area :area
    f.targeable :targeable
  end
end

RSpec::Matchers.define :validate_superior_of do |expected, target|
  match do |actual|
    actual.send(target).children.include?(actual.send(expected))
  end
end

