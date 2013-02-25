#encoding : utf-8
require 'spec_helper'
describe Admins::Shops::TemplatesController do
  def valid_attributes
    {  }
  end

  describe "GET new" do
  	it "测试创建 template" do
  		get :new, {}, get_session
  		assigns(:template).should be_a_new(Admins::Shops::Templates)
  	end
  end

end
