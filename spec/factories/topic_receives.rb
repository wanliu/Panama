# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :topic_receife, :class => 'TopicReceive' do
    topic_id 1
    receive_id 1
    receive_type "MyString"
  end
end
