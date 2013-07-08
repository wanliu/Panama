#encoding: utf-8

FactoryGirl.define do
  factory :province, class: City do |f|
    name "湖南省"
  end

  factory :city, class: City do |f|
    name "衡阳市"
  end

  factory :area, class: City do |f|
    name "耒阳市"
  end
end