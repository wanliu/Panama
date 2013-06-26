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

  describe "POST event 订单状态事件" do

    it "确认订单过期" do
      OrderTransaction.any_instance.should_receive(:valid?).and_return(true)
      transaction = OrderTransaction.create! valid_attributes
      transaction
    end

    describe "快递运输" do
      let(:delivery_manner){ FactoryGirl.create(:express) }

      before do
        @transaction = OrderTransaction.create! valid_attributes
        @transaction.delivery_manner = delivery_manner
      end

      describe "在线付款" do
        let(:online_payment){ FactoryGirl.create(:online_payment) }

        before do
          @transaction.pay_manner = online_payment
          @transaction.save
        end

        it "确认订单 到 等待付款" do
          @transaction.state.should eq("order")
          post :event, person_params.merge({
            :event => :buy,
            :id => @transaction.to_param}), valid_session
          assigns(:transaction).state.should_not eq("waiting_paid")
        end

      end


      describe "货到付款" do
      end

      describe "银行汇款" do
      end

    end

    # it "订单状态变更成功跳转页面" do
    #   transaction = OrderTransaction.create! valid_attributes
    #   post :event, person_params.merge({
    #     :event => :buy,
    #     :id => transaction.to_param}), valid_session
    #   response.should render_template(:partial => "people/transactions/_transaction")
    #   #response.should redirect_to(person_transaction_path(current_user.login, transaction))
    # end
  end
end
