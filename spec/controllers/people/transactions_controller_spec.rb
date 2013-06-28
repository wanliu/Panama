#encoding: utf-8

require 'spec_helper'

describe People::TransactionsController, "用户订单交易流通" do

  let(:valid_session) { get_session }
  let(:ems){ FactoryGirl.create(:ems) }
  let(:cbc){ FactoryGirl.create(:cbc) }
  let(:shop_a) { FactoryGirl.create(:shop, user: anonymous) }
  let(:category_a) { FactoryGirl.create(:category) }
  let(:category_b) { FactoryGirl.create(:category) }
  let(:shops_category_a) { FactoryGirl.create(:shops_category, shop: shop_a) }
  let(:shops_category_b) { FactoryGirl.create(:shops_category, shop: shop_a) }
  let(:product_i) { FactoryGirl.create(:product, shop: shop_a, category: category_a, shops_category: shops_category_a) }
  let(:product_ii) { FactoryGirl.create(:product, shop: shop_a, category: category_b, shops_category: shops_category_b) }
  let(:item_1) { FactoryGirl.create(:product_item, product: product_i, cart: nil) }
  let(:item_2) { FactoryGirl.create(:product_item, product: product_ii, cart: nil) }


  def generate_order
     item_1.cart = my_cart
     item_2.cart = my_cart

     item_1.save
     item_2.save

     my_cart.create_transaction(current_user)
     OrderTransaction.last
  end

  def person_params
    {
      :person_id => current_user.login
    }
  end

  describe "GET index" do
    it "获取用户所有记录" do
      transaction = generate_order
      get :index, person_params, valid_session
      assigns(:transactions).should eq([transaction])
    end
  end

  describe "GET show" do
    it "查看一张单" do
      transaction = generate_order
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
      transaction = generate_order
      expect {
        delete :destroy, person_params.merge({:id => transaction.to_param}), valid_session
      }.to change(OrderTransaction, :count).by(-1)
    end

    it "删除成功跳向url" do
      transaction = generate_order
      delete :destroy, person_params.merge({:id => transaction.to_param}), valid_session
      response.should redirect_to(person_transactions_path(current_user.login))
    end
  end

  describe "POST event 订单状态事件" do

    describe "快递运输" do
      let(:delivery_manner){ FactoryGirl.create(:express) }

      before do
        @transaction = generate_order
        @transaction.delivery_manner = delivery_manner
        @options = person_params.merge(:id => @transaction.to_param)
      end

      describe "在线付款" do
        let(:pay_manner){ FactoryGirl.create(:online_payment) }

        before do
          @transaction.pay_manner = pay_manner
          @transaction.address = current_user_address
          @transaction.delivery_type = ems
          @transaction.save
        end

        it "确认订单 到 等待付款" do
          @transaction.state.should eq("order")
          post :event, @options.merge(:event => :buy), valid_session
          assigns(:transaction).state.should eq("waiting_paid")
        end

        describe do
          before do
            @transaction.buyer_fire_event!(:buy)
            @transaction.buyer.recharge(5000000, cbc)
          end

          it "等待付款 到 等待发货" do
            @transaction.state.should eq("waiting_paid")
            post :event, @options.merge(:event => :paid), valid_session
            assigns(:transaction).state.should eq("waiting_delivery")
          end

          describe do
            before do
              @transaction.buyer_fire_event!(:paid)
              @transaction.delivery_code = "481564646465"
              @transaction.save
              @transaction.seller_fire_event!(:delivered)
            end

            it "等待签收 到 完成" do
              @transaction.state.should eq("waiting_sign")
              post :event, @options.merge(:event => :sign), valid_session
              assigns(:transaction).state.should eq("complete")
            end
          end
        end
      end

      describe "货到付款" do
        let(:pay_manner){ FactoryGirl.create(:cash_on_delivery) }

        before do
          @transaction.pay_manner = pay_manner
          @transaction.address = current_user_address
          @transaction.delivery_type = ems
          @transaction.save
        end

        it "确认订单 到 等待发货" do
          @transaction.state.should eq("order")
          post :event, @options.merge(:event => :buy), valid_session
          assigns(:transaction).state.should eq("waiting_delivery")
        end

        describe do
          before do
            @transaction.buyer_fire_event!(:buy)
            @transaction.delivery_code = "481564646465"
            @transaction.save
            @transaction.seller_fire_event!(:delivered)
          end

          it "等待签收 到 完成" do
            @transaction.state.should eq("waiting_sign")
            post :event, @options.merge(:event => :sign), valid_session
            assigns(:transaction).state.should eq("complete")
          end
        end
      end

      describe "银行汇款" do
        let(:pay_manner){ FactoryGirl.create(:bank_transfer) }
        before do
          @transaction.pay_manner = pay_manner
          @transaction.address = current_user_address
          @transaction.delivery_type = ems
          @transaction.save
        end

        it "确认订单 到 等待汇款" do
          @transaction.state.should eq("order")
          post :event, @options.merge(:event => :buy), valid_session
          assigns(:transaction).state.should eq("waiting_transfer")
        end

        describe do
          let(:transfer_sheet){ FactoryGirl.create(:transfer_sheet, :order_transaction => @order_transaction) }
          before do
            @transaction.buyer_fire_event!(:buy)
            @transaction.transfer_sheet = transfer_sheet
            @transaction.save
          end

          it "等待汇款 到 等待审核" do
            @transaction.state.should eq("waiting_transfer")
            post :event, @options.merge(:event => :transfer), valid_session
            assigns(:transaction).state.should eq("waiting_audit")
          end

          describe do
            before do
              @transaction.buyer_fire_event!(:transfer)
              #审核通过
              @transaction.fire_events!(:audit_transfer)
              @transaction.delivery_code = "5464564544454"
              @transaction.save
              #卖家发货
              @transaction.seller_fire_event!(:delivered)
            end

            it "等待签收 到 完成" do
              @transaction.state.should eq("waiting_sign")
              post :event, @options.merge(:event => :sign), valid_session
              assigns(:transaction).state.should eq("complete")
            end
          end
        end
      end
    end

    describe "本地送货" do
      let(:delivery_manner){ FactoryGirl.create(:local_delivery) }

      before do
        @transaction = generate_order
        @transaction.delivery_manner = delivery_manner
        @options = person_params.merge(:id => @transaction.to_param)
      end

      describe "在线付款" do
        let(:online_payment){ FactoryGirl.create(:online_payment) }

        before do
          @transaction.pay_manner = online_payment
          @transaction.address = current_user_address
          @transaction.delivery_type = ems
          @transaction.save
        end

        it "确认订单 到 等待付款" do
          @transaction.state.should eq("order")
          post :event, @options.merge(:event => :buy), valid_session
          assigns(:transaction).state.should eq("waiting_paid")
        end

        describe do
          before do
            @transaction.buyer_fire_event!(:buy)
            @transaction.buyer.recharge(5000000, cbc)
          end

          it "等待付款 到 等待发货" do
            @transaction.state.should eq("waiting_paid")
            post :event, @options.merge(:event => :paid), valid_session
            assigns(:transaction).state.should eq("waiting_delivery")
          end

          describe do
            before do
              @transaction.buyer_fire_event!(:paid)
              @transaction.seller_fire_event!(:delivered)
            end

            it "等待签收 到 完成" do
              @transaction.state.should eq("waiting_sign")
              post :event, @options.merge(:event => :sign), valid_session
              assigns(:transaction).state.should eq("complete")
            end
          end
        end
      end
    end
  end
end
