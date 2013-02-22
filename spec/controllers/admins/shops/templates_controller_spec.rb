#encoding: utf-8

require 'spec_helper'

describe Admins::Shops::TemplatesController, "模板信息控制器" do

	let(:shop){ FactoryGirl.create(:shop, :user => get_session[:user]) }

	def current_shop
		{ :shop_id => shop.name }
	end

	describe "GET new " do
		it "显示添加" do
			get "new", current_shop, get_session
			response.should be_success
			assigns(:template).should be_a_new(Template)
		end
	end

	describe "GET index" do
		it "查看所有" do
			# get "index", current_shop, get_session
			# response.should be_success
		end
	end
end
