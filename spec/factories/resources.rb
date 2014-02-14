# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :resource do |f|
    name 'index'
    data 'hello world'
    f.content :content
  end
end
