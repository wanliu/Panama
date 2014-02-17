# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :delivery_address do
    zip_code "MyString"
    road "MyString"
    province_id 1
    city_id 1
    area_id 1
    contact_name "MyString"
    contact_phone "MyString"
    deleted_at "2013-10-18 15:17:38"
  end
end
