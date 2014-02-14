# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product_permission, :class => Permission do
    resource "Product"
    ability "create"
  end

  factory :user_permission, :class => Permission do
  	resource "User"
  	ability "update"
  end
end
