#encoding: utf-8

FactoryGirl.define do
  factory :address do |f|
    country '中国CHINA'
    sequence(:road) { |n| "the_#{n}th_road" }
    sequence(:zip_code, 421800) { |n| "#{n}" }
    f.transaction :transaction
    f.user :user
    f.province :province
    f.city :city
    f.area :area
    f.addressable :addressable
  end
end

RSpec::Matchers.define :be_a_validate do |expected|
  match do |actual|
    actual.valid? == expected
  end
end