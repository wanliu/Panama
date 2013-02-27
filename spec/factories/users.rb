# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:uid) { |n| "12345#{n}" }
    sequence(:login) { |n| "test#{n}" }
  end
end
