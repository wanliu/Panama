#encoding: utf-8
require 'spec_helper'

describe People::DeliveryAddressesController, "收货地址控制器" do
	let(:address) { FactoryGirl.create(:address) }

	def person_param
    { :person_id => current_user.login }
  end

	describe "GET index" do
		it "获取所有的" do
			get :index, person_param, get_session
			assigns(:address).should eq([address])
			response.should be_success
		end
	end

	describe "GET edit" do
		it "获得待修改的" do
			get :edit, person_param.merge(:id => address.id), get_session
			assigns(:address).should eq(address)
			response.should be_success
		end
	end
end
