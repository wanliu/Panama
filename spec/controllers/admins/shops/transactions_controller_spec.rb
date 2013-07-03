#encoding: utf-8

require 'spec_helper'

describe Admins::Shops::TransactionsController, "商家订单交易控制器" do
  let(:valid_session) { get_session }
  let(:ems){ FactoryGirl.create(:ems) }
  let(:cbc){ FactoryGirl.create(:cbc) }
  let(:shop) { FactoryGirl.create(:shop, user: current_user) }
  let(:category_a) { FactoryGirl.create(:category) }
  let(:category_b) { FactoryGirl.create(:category) }
  let(:shops_category_a) { FactoryGirl.create(:shops_category, shop: shop) }
  let(:shops_category_b) { FactoryGirl.create(:shops_category, shop: shop) }
  let(:product_i) { FactoryGirl.create(:product, shop: shop, category: category_a, shops_category: shops_category_a) }
  let(:product_ii) { FactoryGirl.create(:product, shop: shop, category: category_b, shops_category: shops_category_b) }
  let(:item_1) { FactoryGirl.create(:product_item, product: product_i, cart: nil) }
  let(:item_2) { FactoryGirl.create(:product_item, product: product_ii, cart: nil) }

  def generate_order
    item_1.cart = my_cart
    item_2.cart = my_cart

    item_1.save
    item_2.save

    my_cart.create_transaction(anonymous)
    OrderTransaction.last
  end

  def shop_param
    {:shop_id => shop.name}
  end

  describe "GET pending" do
    before do
      @order1 = generate_order
      sleep 1
      @order2 = generate_order
    end

    it "待处理" do
      get :pending, shop_param, valid_session
      assigns(:untransactions).should eq([@order2, @order1])
      assigns(:transactions).should eq([])
    end

    it "我处理的" do
      current_user.connect
      @order1.operator_create(current_user.id)
      get :pending, shop_param, valid_session
      assigns(:untransactions).should eq([@order2])
      assigns(:transactions).should eq([@order1])
    end
  end

  describe "GET show" do
    before do
      @order1 = generate_order
    end
    it "显示某个订单信息" do
      get :show, shop_param.merge(:id => @order1.id), valid_session
      assigns(:transaction).should eq(@order1)
      response.should render_template("show")
    end
  end

  describe "POST event 订单事件变更" do
    before do
      @order1 = generate_order
      @order1.address = current_user_address

      @options = shop_param.merge(:id => @order1.id)
      @order2 = generate_order
    end

    describe "快递运输" do
      let(:delivery_manner){ FactoryGirl.create(:express) }
      before do
        @order1.delivery_manner = delivery_manner
        @order1.delivery_type = ems
        @order1.delivery_code = "456879879797"
      end

      describe "货到付款" do
        let(:pay_manner){ FactoryGirl.create(:cash_on_delivery) }
        before do
          @order1.pay_manner = pay_manner
          @order1.save
          @order1.buyer_fire_event!(:buy)
        end

        it "等待发货 到 等待签收" do
          @order1.state.should eq("waiting_delivery")
          post :event, @options.merge(
            :event => :delivered), valid_session
          transaction = assigns(:transaction)
          transaction.id.should eq(@order1.id)
          transaction.state.should eq("waiting_sign")
        end

        describe "GET complete" do
          before do
            @order1.seller_fire_event!(:delivered)
            @order1.buyer_fire_event!(:sign)
          end

          it "交易成功订单" do
            get :complete, shop_param, valid_session
            transactions = assigns(:transactions)
            transactions.select{|t| t.state != "complete"}[0].should be_nil
          end
        end
      end

      describe "在线付款" do
        let(:pay_manner){ FactoryGirl.create(:online_payment) }
        before do
          @order1.pay_manner = pay_manner
          @order1.save
          @order1.buyer_fire_event!(:buy)
          @order1.buyer.recharge(5000000, cbc)
          @order1.buyer_fire_event!(:paid)
        end

        it "等待发货 到 等待签收" do
          @order1.state.should eq("waiting_delivery")
          post :event, @options.merge(
            :event => :delivered), valid_session
          transaction = assigns(:transaction)
          transaction.id.should eq(@order1.id)
          transaction.state.should eq("waiting_sign")
        end

        describe do
          before do
            @order1.seller_fire_event!(:delivered)
            @order1.buyer_fire_event!(:sign)
          end

          it "交易成功订单" do
            get :complete, shop_param, valid_session
            transactions = assigns(:transactions)
            transactions.select{|t| t.state != "complete"}[0].should be_nil
          end
        end
      end

      describe "银行汇款" do
        let(:pay_manner){ FactoryGirl.create(:bank_transfer) }
        let(:transfer_sheet){ FactoryGirl.create(:transfer_sheet, :order_transaction => @order1) }
        before do
          @order1.pay_manner = pay_manner
          @order1.transfer_sheet = transfer_sheet
          @order1.save
          @order1.buyer_fire_event!(:buy)
          @order1.buyer_fire_event!(:transfer)
          @order1.fire_events!(:audit_transfer)
        end

        it "等待发货 到 等待签收" do
          @order1.state.should eq("waiting_delivery")
          post :event, @options.merge(
            :event => :delivered), valid_session
          transaction = assigns(:transaction)
          transaction.id.should eq(@order1.id)
          transaction.state.should eq("waiting_sign")
        end

        describe do
          before do
            @order1.seller_fire_event!(:delivered)
            @order1.buyer_fire_event!(:sign)
          end

          it "交易成功订单" do
            get :complete, shop_param, valid_session
            transactions = assigns(:transactions)
            transactions.select{|t| t.state != "complete"}[0].should be_nil
          end
        end
      end
    end

    describe "本地送货" do
      let(:delivery_manner){ FactoryGirl.create(:local_delivery) }

      before do
        @order1.delivery_manner = delivery_manner
      end

      describe "在线付款" do
        let(:pay_manner){ FactoryGirl.create(:online_payment) }

        before do
          @order1.pay_manner = pay_manner
          @order1.save
          @order1.buyer_fire_event!(:buy)
          @order1.buyer.recharge(5000000, cbc)
          @order1.buyer_fire_event!(:paid)
        end

        it "等待发货 到 等待签收" do
          @order1.state.should eq("waiting_delivery")
          post :event, @options.merge(
            :event => :delivered), valid_session
          transaction = assigns(:transaction)
          transaction.id.should eq(@order1.id)
          transaction.state.should eq("waiting_sign")
        end

        describe do
          before do
            @order1.seller_fire_event!(:delivered)
            @order1.buyer_fire_event!(:sign)
          end

          it "交易成功订单" do
            get :complete, shop_param, valid_session
            transactions = assigns(:transactions)
            transactions.select{|t| t.state != "complete"}[0].should be_nil
          end
        end
      end

      describe "银行汇款" do
        let(:pay_manner){ FactoryGirl.create(:bank_transfer) }
        let(:transfer_sheet){ FactoryGirl.create(:transfer_sheet, :order_transaction => @order1) }
        before do
          @order1.pay_manner = pay_manner
          @order1.transfer_sheet = transfer_sheet
          @order1.save
          @order1.buyer_fire_event!(:buy)
          @order1.buyer_fire_event!(:transfer)
          @order1.fire_events!(:audit_transfer)
        end

        it "等待发货 到 等待签收" do
          @order1.state.should eq("waiting_delivery")
          post :event, @options.merge(
            :event => :delivered), valid_session
          transaction = assigns(:transaction)
          transaction.id.should eq(@order1.id)
          transaction.state.should eq("waiting_sign")
        end

        describe do
          before do
            @order1.seller_fire_event!(:delivered)
            @order1.buyer_fire_event!(:sign)
          end

          it "交易成功订单" do
            get :complete, shop_param, valid_session
            transactions = assigns(:transactions)
            transactions.select{|t| t.state != "complete"}[0].should be_nil
          end
        end
      end

      describe "货到付款" do
        let(:pay_manner){ FactoryGirl.create(:cash_on_delivery) }
        before do
          @order1.pay_manner = pay_manner
          @order1.save
          @order1.buyer_fire_event!(:buy)
        end

        it "等待发货 到 等待签收" do
          @order1.state.should eq("waiting_delivery")
          post :event, @options.merge(
            :event => :delivered), valid_session
          transaction = assigns(:transaction)
          transaction.id.should eq(@order1.id)
          transaction.state.should eq("waiting_sign")
        end

        describe do
          before do
            @order1.seller_fire_event!(:delivered)
            @order1.buyer_fire_event!(:sign)
          end

          it "交易成功订单" do
            get :complete, shop_param, valid_session
            transactions = assigns(:transactions)
            transactions.select{|t| t.state != "complete"}[0].should be_nil
          end
        end
      end
    end
  end

  describe "POST delivery_code" do
    let(:pay_manner){ FactoryGirl.create(:cash_on_delivery) }
    let(:delivery_manner){ FactoryGirl.create(:express) }

    before do
      @order1 = generate_order
      @order1.address = current_user_address
      @order1.pay_manner = pay_manner
      @order1.delivery_manner = delivery_manner
      @order1.delivery_type = ems
      @order1.save
    end

    it "无效订单，填写快递单号" do
      xhr :post, :delivery_code, shop_param.merge(
        :delivery_code => "45646464",
        :id => @order1.id), valid_session
      response.code.should eq("403")
    end

    it "等待发货，填写快递单号" do
      @order1.buyer_fire_event!(:buy)
      @order1.state.should eq("waiting_delivery")
      xhr :post, :delivery_code, shop_param.merge(
        :delivery_code => "6454458",
        :id => @order1.id), valid_session
      response.code.should eq("204")
    end
  end

  describe "POST dispose" do

    before do
      @order1 = generate_order
    end

    it "处理订单" do
      post :dispose, shop_param.merge(
        :id => @order1.id), valid_session
      order = assigns(:transaction)
      order.operator.operator.should eq(current_user)
      response.should be_success
      response.should render_template("transaction")
    end
  end

  describe "GET dialogue" do
    before do
      @order1 = generate_order
    end

    it "显示某个订单的聊天框" do
      get :dialogue, shop_param.merge(
        :id => @order1.id), valid_session
      order = assigns(:transaction)
      order.should eq(@order1)
      response.should render_template("transactions/_dialogue", :layout => "layouts/_transaction_message")
    end
  end

  describe "POST send_message" do
    before do
      @order1 = generate_order
    end

    it "订单发送聊天" do
      content = "你好！有什么可以为你服务！"
      post :send_message, shop_param.merge(
        :message => { :content => content },
        :id => @order1.id), valid_session
      order = assigns(:transaction)
      order.should eq(@order1)
      assigns(:message).content.should eq(content)
      assigns(:message).valid?.should be_true
    end
  end

  describe "GET messages" do
    before do
      @order1 = generate_order
      @m1 = @order1.chat_messages.create(
        :content => "没有什么东西",
        :send_user => current_user,
        :receive_user => @order1.buyer)
      sleep 1
      @m2 = @order1.chat_messages.create(
        :content => "爱买不买！价格没得少啊！",
        :send_user => current_user,
        :receive_user => @order1.buyer)
    end

    it "获取某个订单所有聊天信息" do
      get :messages, shop_param.merge(
        :id => @order1.id), valid_session
      assigns(:messages).should eq([@m2, @m1])
    end
  end
end
