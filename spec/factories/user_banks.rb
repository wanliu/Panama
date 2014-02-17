# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_bank do
    user_id 1
    bank_id 1
    code "MyString"
    name "MyString"
    state false
  end
end
