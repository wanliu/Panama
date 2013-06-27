
FactoryGirl.define do

	factory :activity do
		url "http://test.activity.com"
		start_time Time.now
		end_time Time.now
		price 8.88 
	end
end
