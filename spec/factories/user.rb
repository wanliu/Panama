require "factory_girl"

FactoryGirl.define do 
	factory :login_user, :class => User do 
		uid 123
		login "test_name"		
	end
end