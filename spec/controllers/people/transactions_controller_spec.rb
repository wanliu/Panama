#encoding: utf-8

require 'spec_helper'

describe People::TransactionsController, "用户交易流通" do

  def valid_attributes
    {
      :buyer_id => get_session[:user].id,
      :items_count => 2,
      :seller_id => 3,
      :total => 5
    }
  end

  def valid_session
    get_session
  end

  describe "GET index" do
    it "获取用户所有记录" do
      get :index, {:person_id => get_session[:user].login}, valid_session
      assigns(:transactions).should eq([transaction])
    end
  end

  describe "GET show" do
    it "查看一张单" do
      transaction = OrderTransaction.create! valid_attributes
      get :show, {:id => transaction.to_param, :person_id => get_session[:user].login}, valid_session
      assigns(:transaction).should eq(transaction)
    end
  end

  describe "GET new" do
    it "显示添加页面" do
      get :new, {}, valid_session
      assigns(:transaction).should be_a_new(OrderTransaction)
    end
  end

  describe "GET edit" do
    it "显示编辑页面" do
      transaction = OrderTransaction.create! valid_attributes
      get :edit, {:id => transaction.to_param}, valid_session
      assigns(:transaction).should eq(transaction)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "附加一条记录" do
        expect {
          post :create, {:transaction => valid_attributes}, valid_session
        }.to change(OrderTransaction, :count).by(1)
      end

      it "添加 OrderTransaction对象" do
        post :create, {:transaction => valid_attributes}, valid_session
        assigns(:people_transaction).should be_a(OrderTransaction)
        assigns(:people_transaction).should be_persisted
      end

      it "添加记录重定向" do
        post :create, {:transaction => valid_attributes}, valid_session
        response.should redirect_to(OrderTransaction.last)
      end
    end

    describe "with invalid params" do
      it "添加记录失败" do
        # Trigger the behavior that occurs when invalid params are submitted
        OrderTransaction.any_instance.stub(:save).and_return(false)
        post :create, {:transaction => {  }}, valid_session
        assigns(:transactions).should be_a_new(OrderTransaction)
      end

      it "添加失败重新显示new" do
        # Trigger the behavior that occurs when invalid params are submitted
        OrderTransaction.any_instance.stub(:save).and_return(false)
        post :create, {:transaction => {  }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "修改记录" do
        transaction = OrderTransaction.create! valid_attributes
        OrderTransaction.any_instance.should_receive(:update_attributes).with("items_count" => 3, "total" => 6)
        put :update, {:id => transaction.to_param, :transaction => { :items_count => 3, :total => 6 }}, valid_session
      end

      it "assigns the requested people_transaction as @people_transaction" do
        transaction = OrderTransaction.create! valid_attributes
        put :update, {:id => transaction.to_param, :transaction => valid_attributes}, valid_session
        assigns(:transaction).should eq(transaction)
      end

      it "redirects to the people_transaction" do
        transaction = OrderTransaction.create! valid_attributes
        put :update, {:id => transaction.to_param, :transaction => valid_attributes}, valid_session
        response.should redirect_to(transaction)
      end
    end

    describe "with invalid params" do
      it "assigns the people_transaction as @people_transaction" do
        transaction = OrderTransaction.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        OrderTransaction.any_instance.stub(:save).and_return(false)
        put :update, {:id => transaction.to_param, :transaction => {  }}, valid_session
        assigns(:people_transaction).should eq(transaction)
      end

      it "re-renders the 'edit' template" do
        transaction = OrderTransaction.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        OrderTransaction.any_instance.stub(:save).and_return(false)
        put :update, {:id => transaction.to_param, :transaction => {  }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested people_transaction" do
      transaction = OrderTransaction.create! valid_attributes
      expect {
        delete :destroy, {:id => transaction.to_param}, valid_session
      }.to change(OrderTransaction, :count).by(-1)
    end

    it "redirects to the people_transactions list" do
      transaction = OrderTransaction.create! valid_attributes
      delete :destroy, {:id => transaction.to_param}, valid_session
      response.should redirect_to(people_transactions_url)
    end
  end

end
