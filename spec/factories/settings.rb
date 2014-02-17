# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :setting do
    var "MyString"
    value "MyString"
    target_id 1
    target_type "MyString"
  end
end
