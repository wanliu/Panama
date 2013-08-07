# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shop_bank do
    shop_id 1
    bank_id 1
    code "MyString"
    name "MyString"
    state false
  end
end
