# encoding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  describe "#current_user" do

    before(:each) do
      @user = User.create!(:uid => '12345', :login => 'test_user')
    end

    describe "错误的方式" do

      it "修复 current_user 恢复过多数据错误" do
        session[:user] = @user
        current_user.should_not eql(@user)
      end
    end


    describe "正确的方式" do

      it "修复 current_user 恢复过多数据错误" do
        session[:omniauth] = { 'uid' => '12345' }
        current_user.should == @user
      end
    end
  end
end