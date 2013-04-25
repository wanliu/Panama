# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :circle_friend_following, :class => 'CircleFriendFollowings' do
    following 1
    circle_friend_id 1
  end
end
