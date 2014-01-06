# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transfer_money do
    to_id 1
    from_id 1
    owner_type "MyString"
    owner_id 1
    decription "MyString"
    money "9.99"
  end
end
