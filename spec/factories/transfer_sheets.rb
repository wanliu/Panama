# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transfer_sheet do
    person "MyString"
    code "MyString"
    bank "MyString"
  end
end
