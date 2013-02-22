#encoding: utf-8

require 'spec_helper'

describe People::TransactionsController, "用户交易流通" do

  def valid_attributes
    {  }
  end

  def valid_session
    get_sessioin
  end

  describe "GET index" do
    it "获取用户所有记录" do
      get :index, {:person_id => get_sessioin[:user].login}, valid_session
      assigns(:people_transactions).should eq([transaction])
    end
  end

  describe "GET show" do
    it "assigns the requested people_transaction as @people_transaction" do
      transaction = People::Transaction.create! valid_attributes
      get :show, {:id => transaction.to_param}, valid_session
      assigns(:people_transaction).should eq(transaction)
    end
  end

  describe "GET new" do
    it "assigns a new people_transaction as @people_transaction" do
      get :new, {}, valid_session
      assigns(:people_transaction).should be_a_new(People::Transaction)
    end
  end

  describe "GET edit" do
    it "assigns the requested people_transaction as @people_transaction" do
      transaction = People::Transaction.create! valid_attributes
      get :edit, {:id => transaction.to_param}, valid_session
      assigns(:people_transaction).should eq(transaction)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new People::Transaction" do
        expect {
          post :create, {:people_transaction => valid_attributes}, valid_session
        }.to change(People::Transaction, :count).by(1)
      end

      it "assigns a newly created people_transaction as @people_transaction" do
        post :create, {:people_transaction => valid_attributes}, valid_session
        assigns(:people_transaction).should be_a(People::Transaction)
        assigns(:people_transaction).should be_persisted
      end

      it "redirects to the created people_transaction" do
        post :create, {:people_transaction => valid_attributes}, valid_session
        response.should redirect_to(People::Transaction.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved people_transaction as @people_transaction" do
        # Trigger the behavior that occurs when invalid params are submitted
        People::Transaction.any_instance.stub(:save).and_return(false)
        post :create, {:people_transaction => {  }}, valid_session
        assigns(:people_transaction).should be_a_new(People::Transaction)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        People::Transaction.any_instance.stub(:save).and_return(false)
        post :create, {:people_transaction => {  }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested people_transaction" do
        transaction = People::Transaction.create! valid_attributes
        # Assuming there are no other people_transactions in the database, this
        # specifies that the People::Transaction created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        People::Transaction.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, {:id => transaction.to_param, :people_transaction => { "these" => "params" }}, valid_session
      end

      it "assigns the requested people_transaction as @people_transaction" do
        transaction = People::Transaction.create! valid_attributes
        put :update, {:id => transaction.to_param, :people_transaction => valid_attributes}, valid_session
        assigns(:people_transaction).should eq(transaction)
      end

      it "redirects to the people_transaction" do
        transaction = People::Transaction.create! valid_attributes
        put :update, {:id => transaction.to_param, :people_transaction => valid_attributes}, valid_session
        response.should redirect_to(transaction)
      end
    end

    describe "with invalid params" do
      it "assigns the people_transaction as @people_transaction" do
        transaction = People::Transaction.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        People::Transaction.any_instance.stub(:save).and_return(false)
        put :update, {:id => transaction.to_param, :people_transaction => {  }}, valid_session
        assigns(:people_transaction).should eq(transaction)
      end

      it "re-renders the 'edit' template" do
        transaction = People::Transaction.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        People::Transaction.any_instance.stub(:save).and_return(false)
        put :update, {:id => transaction.to_param, :people_transaction => {  }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested people_transaction" do
      transaction = People::Transaction.create! valid_attributes
      expect {
        delete :destroy, {:id => transaction.to_param}, valid_session
      }.to change(People::Transaction, :count).by(-1)
    end

    it "redirects to the people_transactions list" do
      transaction = People::Transaction.create! valid_attributes
      delete :destroy, {:id => transaction.to_param}, valid_session
      response.should redirect_to(people_transactions_url)
    end
  end

end
