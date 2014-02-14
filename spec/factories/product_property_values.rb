# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product_property_value do
    product_property_id 1
    value "MyString"
  end
end
