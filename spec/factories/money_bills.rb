# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :money_bill do
    serial_number "MyString"
    money "9.99"
    decription "MyText"
    user_id 1
    owner_id 1
    owner_type "MyString"
  end
end
