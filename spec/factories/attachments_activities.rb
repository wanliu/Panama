# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attachments_activity, :class => 'AttachmentsActivities' do
    attachment_id 1
    activity_id "MyString"
    integer "MyString"
    number 1
  end
end
