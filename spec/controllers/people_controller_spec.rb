#encoding: utf-8
require 'spec_helper'

describe PeopleController, "个人信息控制器" do

  let(:shop){ FactoryGirl.create(:shop, user: anonymous) }

  def generate_auth_string(now = DateTime.now)
    r1, r2 = rand(999), rand(999)
    Crypto.encrypt("#{now}|#{r1}|#{r2}|#{r1+r2}")
  end

  describe "GET 'show'" do
    it "访问个人页面" do
      get 'show', {id: current_user.login}, get_session
      response.should be_success
      assigns(:people).should eql(current_user)
    end
  end

  context "邀请用户" do
    before :each do
      @opts = {
        shop_name: Crypto.encrypt(shop.name),
        login: Crypto.encrypt(current_user.login),
        auth: generate_auth_string
      }
    end

    describe "GET show_invite 显示用户邀请信息" do
      it "无效的商店邀请" do
        get :show_invite, @opts.merge({shop_name: "15464fdsa"}), get_session
        response.should render_template("errors/errors_403")
        response.should render_template("layouts/error")
        response.response_code.should eq(403)
      end

      it "无效的用户邀请" do
        get :show_invite, @opts.merge({login: "54641fdas"}), get_session
        response.should render_template("errors/errors_403")
        response.should render_template("layouts/error")
        response.response_code.should eq(403)
      end

      it "过期邀请信息" do
        get :show_invite, @opts.merge({auth: generate_auth_string(DateTime.now-4.day)}), get_session
        response.should render_template("errors/errors_403")
        response.should render_template("layouts/error")
        response.response_code.should eq(403)
      end

      it "验证通过" do
        get :show_invite, @opts, get_session
        response.should be_success
        response.should render_template(:show_invite)
      end
    end

    describe "POST agree_invite_user 接受邀请" do

      it "无效的用户邀请" do
        post :agree_invite_user, @opts.merge(login: "15616fdsaf"), get_session
        response.should render_template("errors/errors_403")
        response.should render_template("layouts/error")
        response.response_code.should eq(403)
      end

      it "无效的商店邀请" do
        post :agree_invite_user, @opts.merge(shop_name: "15616fdsaf"), get_session
        response.should render_template("errors/errors_403")
        response.should render_template("layouts/error")
        response.response_code.should eq(403)
      end

      it "邀请信息过期" do
        post :agree_invite_user, @opts.merge(auth: DateTime.now-4.day), get_session
        response.should render_template("errors/errors_403")
        response.should render_template("layouts/error")
        response.response_code.should eq(403)
      end

      it "邀请成功" do
        shop.shop_users.find_by(user_id: current_user.id).should be_nil

        post :agree_invite_user, @opts, get_session
        user = shop.shop_users.find_by(user_id: current_user.id).user
        user.should eq(current_user)
        response.should redirect_to(person_path(current_user.login))
      end
    end
  end

  context "Email 邀请" do
    before :each do
      @opts = {
        shop_name: Crypto.encrypt(shop.name),
        auth: generate_auth_string
      }
    end

    describe "Get show_email_invite 显示信息" do

      it "无效的商店邀请" do
        get :show_email_invite, @opts.merge(shop_name: "fdsa32fd"), get_session
        response.should render_template("errors_403")
        response.response_code.should eq(403)
      end

      it "邀请信息过期" do
        get :show_email_invite, @opts.merge(auth: DateTime.now-4.day), get_session
        response.should render_template("errors_403")
        response.response_code.should eq(403)
      end

      it "验证通过" do
        get :show_email_invite, @opts, get_session
        response.should be_success
        response.should render_template(:show_invite)
      end

      it "获取登陆的用户" do
        get :show_email_invite, @opts, get_session
        assigns(:people).should eq(current_user)
      end
    end

    describe "POST agree_email_invite_user 接受E-mail邀请" do

      it "无效的商店邀请" do
        post :agree_email_invite_user, @opts.merge(shop_name: "fdsa32fd"), get_session
        response.should render_template("errors_403")
        response.response_code.should eq(403)
      end

      it "邀请信息过期" do
        post :agree_email_invite_user, @opts.merge(auth: DateTime.now-4.day), get_session
        response.should render_template("errors_403")
        response.response_code.should eq(403)
      end

      it "验证通过" do
        post :agree_email_invite_user, @opts, get_session
        assigns(:people).should eq(current_user)
        user = shop.shop_users.find_by(user_id: current_user.id).user
        user.should eq(current_user)
        response.should redirect_to(person_path(current_user))
      end

    end

  end


end
