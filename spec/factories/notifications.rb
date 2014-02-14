#encoding: utf-8

FactoryGirl.define do
  factory :notification do | f |
    f.user :user
    f.mentionable_user :mentionable_user
    f.read false
    f.url "http://localhost:3000/people/kaka"
    f.body "我在这里提及到你了"
  end
end
