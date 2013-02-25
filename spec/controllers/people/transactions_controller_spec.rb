#encoding: utf-8

require 'spec_helper'

describe People::TransactionsController, "用户交易流通" do

  def valid_attributes
    {  }
  end

  def valid_session
    get_session
  end

  let(:current_user) { get_session[:user] }
  let(:pepsi) { FactoryGirl.create(:shop, user: current_user) }
  let(:transaction) { FactoryGirl.create(:transaction,
                                         buyer: current_user,
                                         seller: pepsi ) }

  def transaction_attributes(transaction, options = {})
    options[:id] = transaction.to_param
    options[:person_id] ||= current_user.login
    options[:order_transaction] ||= options.fetch :order_transaction, {}
    options
  end

  describe "GET index" do
    it "获取用户所有记录" do
      get :index, {:person_id => current_user.login}, valid_session
      assigns(:transactions).should eq([transaction])
    end
  end

  describe "GET show" do
    it "assigns the requested people_transaction as @transaction" do
      get :show, transaction_attributes(transaction), valid_session
      assigns(:transaction).should eq(transaction)
    end
  end

  describe "GET new" do
    it "assigns a new people_transaction as @transaction" do
      get :new, {}, valid_session
      assigns(:transaction).should be_a_new(OrderTransaction)
    end
  end

  describe "GET edit" do
    it "assigns the requested people_transaction as @transaction" do
      get :edit, transaction_attributes(transaction), valid_session
      assigns(:transaction).should eq(transaction)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new OrderTransaction" do
        expect {
          post :create, transaction_attributes(transaction), valid_session
        }.to change(OrderTransaction, :count).by(1)
      end

      it "assigns a newly created people_transaction as @transaction" do
        post :create, transaction_attributes(transaction), valid_session

        assigns(:transaction).should be_a(OrderTransaction)
        assigns(:transaction).should be_persisted
      end

      it "redirects to the created people_transaction" do
        post :create, transaction_attributes(transaction), valid_session
        response.should redirect_to(person_transaction_path(current_user, OrderTransaction.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved people_transaction as @transaction" do
        # Trigger the behavior that occurs when invalid params are submitted
        OrderTransaction.any_instance.stub(:save).and_return(false)
        post :create, transaction_attributes(transaction), valid_session
        assigns(:transaction).should be_a_new(OrderTransaction)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        OrderTransaction.any_instance.stub(:save).and_return(false)
        post :create, transaction_attributes(transaction), valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested people_transaction" do
        # Assuming there are no other people_transactions in the database, this
        # specifies that the OrderTransaction created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        OrderTransaction.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, transaction_attributes(transaction, :order_transaction => { "these" => "params" }), valid_session
      end

      it "assigns the requested people_transaction as @transaction" do
        put :update, transaction_attributes(transaction), valid_session
        assigns(:order_transaction).should eq(transaction)
      end

      it "redirects to the people_transaction" do
        put :update, transaction_attributes(transaction), valid_session
        response.should redirect_to(person_transaction_path(current_user, OrderTransaction.last))
      end
    end

    describe "with invalid params" do
      it "assigns the people_transaction as @transaction" do
        # Trigger the behavior that occurs when invalid params are submitted
        OrderTransaction.any_instance.stub(:save).and_return(false)
        put :update, transaction_attributes(transaction), valid_session
        assigns(:order_transaction).should eq(transaction)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        OrderTransaction.any_instance.stub(:save).and_return(false)
        put :update, transaction_attributes(transaction), valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested people_transaction" do
      expect {
        delete :destroy, transaction_attributes(transaction), valid_session
      }.to change(OrderTransaction, :count).by(-1)
    end

    it "redirects to the people_transactions list" do
      delete :destroy, transaction_attributes(transaction), valid_session
      response.should redirect_to([:hysios, people_transactions_url])
    end
  end

end
