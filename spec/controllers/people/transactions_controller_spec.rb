#encoding: utf-8

require 'spec_helper'

describe People::TransactionsController, "用户订单交易流通" do

  let(:valid_session) { get_session }
  let(:shop){ FactoryGirl.create(:shop, :user => FactoryGirl.create(:user)) }

  def valid_attributes
    {
      :buyer_id => current_user.id,
      :items_count => 2,
      :seller_id => shop.id,
      :total => 5,
      :address_id => 3
    }
  end

  def person_params
    {
      :person_id => current_user.login
    }
  end

  describe "GET index" do
    it "获取用户所有记录" do
      transaction = OrderTransaction.create! valid_attributes
      get :index, person_params, valid_session
      assigns(:transactions).should eq([transaction])
    end
  end

  describe "GET show" do
    it "查看一张单" do
      transaction = OrderTransaction.create! valid_attributes
      get :show, person_params.merge({:id => transaction.to_param}), valid_session
      assigns(:transaction).should eq(transaction)
    end
  end

  describe "GET new" do
    it "显示添加页面" do
      get :new, {:person_id => ""}, valid_session
      assigns(:transaction).should be_a_new(OrderTransaction)
    end
  end

  describe "GET edit" do
    it "显示编辑页面" do
      transaction = OrderTransaction.create! valid_attributes
      get :edit, {:id => transaction.to_param,:person_id => ""}, valid_session
      assigns(:transaction).should eq(transaction)
    end
  end

  describe "POST batch_create" do
    it "生成成功" do
      Cart.any_instance.should_receive(:create_transaction).with(current_user).and_return(true)
      post :batch_create, person_params.merge(:id => ""), valid_session
      response.should redirect_to(person_transactions_path(current_user.login))
    end

    it "生成失败" do
      Cart.any_instance.should_receive(:create_transaction).with(current_user).and_return(false)
      post :batch_create, person_params.merge(:id => ""), valid_session
      response.should redirect_to(person_cart_index_path(current_user.login))
    end
  end

  describe "POST create" do
    describe "with valid params" do
      before :each do
        @options = person_params.merge({:order_transaction => valid_attributes})
      end

      it "附加一条记录" do
        expect {
          post :create, @options, valid_session
        }.to change(OrderTransaction, :count).by(1)
      end

      it "添加 OrderTransaction对象" do
        post :create, @options, valid_session
        assigns(:transaction).should be_a(OrderTransaction)
        assigns(:transaction).should be_persisted
      end

      it "添加记录重定向" do
        post :create, @options, valid_session
        response.should redirect_to(person_transaction_path(current_user.login, assigns(:transaction)))
      end
    end

    describe "with invalid params" do
      it "添加记录失败" do
        # Trigger the behavior that occurs when invalid params are submitted
        OrderTransaction.any_instance.stub(:save).and_return(false)
        post :create, person_params.merge({:transaction => {  }}), valid_session
        assigns(:transaction).should be_a_new(OrderTransaction)
      end

      it "添加失败重新显示new" do
        # Trigger the behavior that occurs when invalid params are submitted
        OrderTransaction.any_instance.stub(:save).and_return(false)
        post :create, person_params.merge({:transaction => {  }}), valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "修改记录" do
        transaction = OrderTransaction.create! valid_attributes
        OrderTransaction.any_instance.should_receive(:update_attributes).with("items_count" => "3", "total" => "6")
        put :update, person_params.merge({
          :id => transaction.to_param,
          :order_transaction => { :items_count => 3, :total => 6 }}), valid_session
      end

      it "修改成功" do
        transaction = OrderTransaction.create! valid_attributes
        put :update, person_params.merge({
          :id => transaction.to_param,
          :transaction => valid_attributes}), valid_session
        assigns(:transaction).should eq(transaction)
      end

      it "修改成功跳转" do
        transaction = OrderTransaction.create! valid_attributes
        put :update, person_params.merge({
          :id => transaction.to_param,
          :transaction => valid_attributes}), valid_session
        response.should redirect_to(person_transaction_path(current_user.login, transaction))
      end
    end

    describe "with invalid params" do
      it "修改失败" do
        transaction = OrderTransaction.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        OrderTransaction.any_instance.stub(:save).and_return(false)
        put :update, {:id => transaction.to_param, :transaction => {  },:person_id => ""}, valid_session
        assigns(:transaction).should eq(transaction)
      end

      it "修改失败显示编辑状态" do
        transaction = OrderTransaction.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        OrderTransaction.any_instance.stub(:save).and_return(false)
        put :update, {:id => transaction.to_param, :transaction => {  },:person_id => ""}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "删除记录" do
      transaction = OrderTransaction.create! valid_attributes
      expect {
        delete :destroy, person_params.merge({:id => transaction.to_param}), valid_session
      }.to change(OrderTransaction, :count).by(-1)
    end

    it "删除成功跳向url" do
      transaction = OrderTransaction.create! valid_attributes
      delete :destroy, person_params.merge({:id => transaction.to_param}), valid_session
      response.should redirect_to(person_transactions_path(current_user.login))
    end
  end

  describe "POST event" do

    it "订单状态变更" do
      transaction = OrderTransaction.create! valid_attributes
      post :event, person_params.merge({
        :event => :buy,
        :id => transaction.to_param}), valid_session
      assigns(:transaction).state.should_not eq(:order)
    end

    it "订单状态变更成功跳转页面" do
      transaction = OrderTransaction.create! valid_attributes
      post :event, person_params.merge({
        :event => :buy,
        :id => transaction.to_param}), valid_session
      response.should render_template(:partial => "people/transactions/_transaction")
      #response.should redirect_to(person_transaction_path(current_user.login, transaction))
    end
  end
end
