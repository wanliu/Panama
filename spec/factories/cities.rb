#encoding: utf-8

FactoryGirl.define do
  factory :province, class: City do |f|
    name "湖南"
  end

  factory :city, class: City do |f|
    name "衡阳"
  end

  factory :area, class: City do |f|
    name "耒阳"
  end
end