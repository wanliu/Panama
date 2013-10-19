# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :community_notification do
    notification_id 1
    state false
    body "MyText"
  end
end
