# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shops_user, :class => 'ShopsUsers' do
    shop_id 1
    user_id 1
  end
end
