# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category_property_value do
    category_property_id 1
    value "MyString"
  end
end
