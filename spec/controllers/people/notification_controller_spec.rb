#encoding: utf-8
#author: huxinghai

require "spec_helper"

describe People::NotificationsController, "提醒通知控制器" do

	let(:notification){  FactoryGirl.create(:notification,
		:user => current_user, :mentionable_user => anonymous ) }

	def person_param
		{:person_id => current_user.login}
	end

	describe "GET index" do
		before :each do
			notification.reload
		end

		it "获取所有未读的" do
			get :index, person_param , get_session

			assigns(:notifications).should eq([notification])
			assigns(:notifications).select{| n | n.read.should be_false }
		end

		it "获取所有" do
			n = Notification.create(:user_id => current_user.id,
				:mentionable_user_id => anonymous.id, :url => "http://localhost:3000", :body => "提示信息")
			get :index, person_param.merge({:all => 1}), get_session
			assigns(:notifications).should eq([notification, n])
		end
	end
end