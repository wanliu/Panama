#encoding: utf-8
require 'spec_helper'

describe OrderTransaction, "订单流通记录" do

  let(:seller){ FactoryGirl.create(:user)}
  let(:buyer){ FactoryGirl.create(:user)}
  let(:ems){ FactoryGirl.create(:ems) }
  let(:cbc){ FactoryGirl.create(:cbc) }
  let(:shop_a) { FactoryGirl.create(:shop, user: seller) }
  let(:category_a) { FactoryGirl.create(:category) }
  let(:category_b) { FactoryGirl.create(:category) }
  let(:shops_category_a) { FactoryGirl.create(:shops_category, shop: shop_a) }
  let(:shops_category_b) { FactoryGirl.create(:shops_category, shop: shop_a) }
  let(:product_i) { FactoryGirl.create(:product, shop: shop_a, category: category_a, shops_category: shops_category_a) }
  let(:product_ii) { FactoryGirl.create(:product, shop: shop_a, category: category_b, shops_category: shops_category_b) }
  let(:item_1) { FactoryGirl.create(:product_item, product: product_i, cart: nil) }
  let(:item_2) { FactoryGirl.create(:product_item, product: product_ii, cart: nil) }
  let(:icbc){ FactoryGirl.create(:icbc) }


  it{ should belong_to(:address) }
  it{ should belong_to(:seller) }
  it{ should belong_to(:buyer) }
  it{ should have_many(:items) }

  it{ should validate_presence_of(:buyer) }
  it{ should validate_presence_of(:seller) }
  # it{ should validate_numericality_of(:items_count) }
  # it{ should validate_numericality_of(:total) }

  def generate_order
    item_1.cart = my_cart
    item_2.cart = my_cart

    item_1.save
    item_2.save

    my_cart.create_transaction(current_user)
    OrderTransaction.last
  end

  it "检查属性" do
    transaction = OrderTransaction.new
    transaction.should respond_to(:items_count)
    transaction.should respond_to(:total)
    transaction.should respond_to(:state)
  end

  it "数据验证" do
    transaction = generate_order
    transaction.save.should be_true

    transaction.buyer_id = nil
    transaction.save.should be_false

    transaction.buyer_id = anonymous.id
    transaction.save.should be_true

    transaction.total = "a"
    transaction.save.should be_false

    transaction.total = 324
    transaction.save.should be_true
  end

  it "初始化状态" do
    generate_order.order?.should be_true
  end

  it "创建订单, 自动计算总和" do
    order = generate_order
    order.total.should eq(order.items.inject(0){|s, item| s + item.total })
  end

  it "订单总和(加运费)" do
    order = generate_order
    order.delivery_price = 10
    total = order.items.inject(0){|s, item| s + item.total}
    order.stotal.should eq(total + order.delivery_price)
  end

  describe "订单状态流程" do
    before do
      @order = generate_order
      @order.address = current_user_address
    end

    describe "快递运输" do
      let(:delivery_manner){ FactoryGirl.create(:express) }
      before do
        @order.delivery_type = ems
        @order.delivery_manner = delivery_manner
      end

      describe "在线付款" do
        let(:pay_manner){ FactoryGirl.create(:online_payment) }

        before do
          @order.pay_manner = pay_manner
          @order.save
        end

        it "确认订单 到 等待付款" do
          @order.state.should eq("order")
          @order.buyer_fire_event!(:buy)
          @order.state.should eq("waiting_paid")
        end

        it "没有选择运输公司" do
          @order.delivery_type = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择付款方式" do
          @order.pay_manner = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择运输方式" do
          @order.delivery_manner = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择送货地址" do
          @order.address = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        describe do
          before do
            @order.buyer_fire_event!(:buy)
          end

          it "付款, 买家余额不足" do
            @order.valid_payment?.empty?.should be_false
            @order.fire_events(:paid).should be_false
          end

          it "用户网上银行充值" do
            @order.buyer.recharge(3000, icbc)
            @order.buyer.money.should eq(3000.to_d)
          end

          it "等待付款 到 等待发货" do
            @order.buyer.recharge(@order.stotal, icbc)
            @order.state.should eq("waiting_paid")
            @order.buyer_fire_event!(:paid)
            @order.state.should eq("waiting_delivery")
            @order.buyer.money.should eq(0.to_d)
          end

          describe do
            before do
              @order.buyer.recharge(@order.stotal, icbc)
              @order.buyer_fire_event!(:paid)
              @order.delivery_code = "45648431321321"
              @order.save
            end

            it "没有填写快递单号" do
              @order.delivery_code = nil
              @order.save.should be_true
              @order.fire_events(:delivered)
            end

            it "等待发货 到 等待签收" do
              @order.state.should eq("waiting_delivery")
              @order.seller_fire_event!(:delivered)
              @order.state.should eq("waiting_sign")
            end

            describe do
              before do
                @order.seller_fire_event!(:delivered)
              end

              it "等待签收 到 完成" do
                @order.state.should eq("waiting_sign")
                @order.buyer_fire_event!(:sign)
                @order.state.should eq("complete")
              end
            end
          end
        end
      end

      describe "银行汇款" do
        let(:pay_manner){ FactoryGirl.create(:bank_transfer) }

        before do
          @order.pay_manner = pay_manner
          @order.save
        end

        it "确认订单 到 等待汇款" do
          @order.state.should eq("order")
          @order.buyer_fire_event!(:buy)
          @order.state.should eq("waiting_transfer")
        end

        it "没有选择运输公司" do
          @order.delivery_type = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择付款方式" do
          @order.pay_manner = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择运输方式" do
          @order.delivery_manner = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择送货地址" do
          @order.address = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        describe do
          before do
            @order.buyer_fire_event!(:buy)
            @order.create_transfer(
              :code => "9551155464656464",
              :bank => "中国农业银行",
              :person => "李四")
          end

          it "存在汇款单" do
            @order.transfer_sheet.should_not be_nil
          end

          it "没有汇款单" do
            @order.transfer_sheet.destroy
            @order.transfer_sheet = nil
            @order.fire_events(:transfer).should be_false
          end

          it "等待汇款 到 汇款审核" do
            @order.state.should eq("waiting_transfer")
            @order.buyer_fire_event!(:transfer)
            @order.state.should eq("waiting_audit")
          end

          describe do
            before do
              @order.fire_events!(:transfer)
            end

            it "汇款审核 到 等待发货" do
              @order.state.should eq("waiting_audit")
              @order.fire_events!(:audit_transfer)
              @order.state.should eq("waiting_delivery")
            end

            it "汇款审核 到 审核不通过" do
              @order.state.should eq("waiting_audit")
              @order.fire_events!(:audit_failure)
              @order.state.should eq("waiting_audit_failure")
            end

            describe do
              before do
                @order.fire_events!(:audit_transfer)
                @order.delivery_code = "8774546456487855"
                @order.save
              end

              it "等待发货 到 等待签收" do
                @order.state.should eq("waiting_delivery")
                @order.seller_fire_event!(:delivered)
                @order.state.should eq("waiting_sign")
              end

              it "没有填写快递单号" do
                @order.delivery_code = nil
                @order.save.should be_true
                @order.fire_events(:delivered).should be_false
              end

              describe do
                before do
                  @order.seller_fire_event!(:delivered)
                end

                it "等待签收 到 完成" do
                  @order.state.should eq("waiting_sign")
                  @order.buyer_fire_event!(:sign)
                  @order.state.should eq("complete")
                end
              end
            end
          end
        end
      end

      describe "货到付款" do
        let(:pay_manner){ FactoryGirl.create(:cash_on_delivery) }

        before do
          @order.pay_manner = pay_manner
          @order.save
        end

        it "确认订单 到 等待发货" do
          @order.state.should eq("order")
          @order.buyer_fire_event!(:buy)
          @order.state.should eq("waiting_delivery")
        end

        it "没有选择运输公司" do
          @order.delivery_type = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择付款方式" do
          @order.pay_manner = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择运输方式" do
          @order.delivery_manner = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择送货地址" do
          @order.address = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "refund_handle_detail_return_money 会调用 unshipped_state 方法" do
          refund = mock("OrderRefund")
          @order.should_receive("unshipped_state?").and_return(false)
          @order.refund_handle_detail_return_money(refund)
        end

        describe do
          before do
            @order.buyer_fire_event!(:buy)
            @order.delivery_code = "46456454645"
            @order.save
          end

          it "没有填写快递单号" do
            @order.delivery_code = nil
            @order.save.should be_true
            @order.fire_events("delivered").should be_false
          end

          it "等待发货 到 等待签收" do
            @order.state.should eq("waiting_delivery")
            @order.seller_fire_event!("delivered")
            @order.state.should eq("waiting_sign")
          end

          describe "refund_handle_detail_return_money" do
            before do
              @refund = mock("OrderRefund")
            end

            it "判断是否及时退货" do
              @order.should_receive("unshipped_state?").and_return(true)
              @order.refund_handle_detail_return_money(@refund)
            end

            it "删除明细，返回钱给买家" do
              @order.items.should_receive("destroy_all")
              @order.should_receive("save").and_return(true)
              @refund.should_receive("buyer_recharge")
              @order.refund_handle_detail_return_money(@refund)
            end
          end

          describe do
            before do
              @order.seller_fire_event!("delivered")
            end

            it "等待签收 到 完成" do
              @order.state.should eq("waiting_sign")
              @order.buyer_fire_event!(:sign)
              @order.state.should eq("complete")
            end
          end
        end
      end
    end

    describe "本地送货" do
      let(:delivery_manner){ FactoryGirl.create(:local_delivery) }

      before do
        @order.delivery_manner = delivery_manner
      end

      describe "在线付款" do
        let(:pay_manner){ FactoryGirl.create(:online_payment) }

        before do
          @order.pay_manner = pay_manner
          @order.save
        end

        it "确认订单 到 等待付款" do
          @order.state.should eq("order")
          @order.buyer_fire_event!(:buy)
          @order.state.should eq("waiting_paid")
        end

        it "没有选择付款方式" do
          @order.pay_manner = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择运输方式" do
          @order.delivery_manner = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择送货地址" do
          @order.address = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        describe do
          before do
            @order.buyer_fire_event!(:buy)
          end

          it "付款, 买家余额不足" do
            @order.valid_payment?.empty?.should be_false
            @order.fire_events(:paid).should be_false
          end

          it "用户网上银行充值" do
            @order.buyer.recharge(3000, icbc)
            @order.buyer.money.should eq(3000.to_d)
          end

          it "等待付款 到 等待发货" do
            @order.buyer.recharge(@order.stotal, icbc)
            @order.state.should eq("waiting_paid")
            @order.buyer_fire_event!(:paid)
            @order.state.should eq("waiting_delivery")
            @order.buyer.money.should eq(0.to_d)
          end

          describe do
            before do
              @order.buyer.recharge(@order.stotal, icbc)
              @order.buyer_fire_event!(:paid)
            end

            it "等待发货 到 等待签收" do
              @order.state.should eq("waiting_delivery")
              @order.seller_fire_event!(:delivered)
              @order.state.should eq("waiting_sign")
            end

            describe do
              before do
                @order.seller_fire_event!(:delivered)
              end

              it "等待签收 到 完成" do
                @order.state.should eq("waiting_sign")
                @order.buyer_fire_event!(:sign)
                @order.state.should eq("complete")
              end
            end
          end
        end
      end

      describe "银行汇款" do
        let(:pay_manner){ FactoryGirl.create(:bank_transfer) }

        before do
          @order.pay_manner = pay_manner
          @order.save
        end

        it "确认订单 到 等待汇款" do
          @order.state.should eq("order")
          @order.buyer_fire_event!(:buy)
          @order.state.should eq("waiting_transfer")
        end

        it "没有选择付款方式" do
          @order.pay_manner = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择运输方式" do
          @order.delivery_manner = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择送货地址" do
          @order.address = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        describe do
          before do
            @order.buyer_fire_event!(:buy)
            @order.create_transfer(
              :code => "9551155464656464",
              :bank => "中国农业银行",
              :person => "李四")
          end

          it "存在汇款单" do
            @order.transfer_sheet.should_not be_nil
          end

          it "没有汇款单" do
            @order.transfer_sheet.destroy
            @order.transfer_sheet = nil
            @order.fire_events(:transfer).should be_false
          end

          it "等待汇款 到 汇款审核" do
            @order.state.should eq("waiting_transfer")
            @order.buyer_fire_event!(:transfer)
            @order.state.should eq("waiting_audit")
          end

          describe do
            before do
              @order.fire_events!(:transfer)
            end

            it "汇款审核 到 等待发货" do
              @order.state.should eq("waiting_audit")
              @order.fire_events!(:audit_transfer)
              @order.state.should eq("waiting_delivery")
            end

            it "汇款审核 到 审核不通过" do
              @order.state.should eq("waiting_audit")
              @order.fire_events!(:audit_failure)
              @order.state.should eq("waiting_audit_failure")
            end

            describe do
              before do
                @order.fire_events!(:audit_transfer)
              end

              it "等待发货 到 等待签收" do
                @order.state.should eq("waiting_delivery")
                @order.seller_fire_event!(:delivered)
                @order.state.should eq("waiting_sign")
              end

              describe do
                before do
                  @order.seller_fire_event!(:delivered)
                end

                it "等待签收 到 完成" do
                  @order.state.should eq("waiting_sign")
                  @order.buyer_fire_event!(:sign)
                  @order.state.should eq("complete")
                end
              end
            end
          end
        end
      end

      describe "货到付款" do
        let(:pay_manner){ FactoryGirl.create(:cash_on_delivery) }

        before do
          @order.pay_manner = pay_manner
          @order.save
        end

        it "确认订单 到 等待发货" do
          @order.state.should eq("order")
          @order.buyer_fire_event!(:buy)
          @order.state.should eq("waiting_delivery")
        end

        it "没有选择付款方式" do
          @order.pay_manner = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择运输方式" do
          @order.delivery_manner = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        it "没有选择送货地址" do
          @order.address = nil
          @order.save.should be_true
          @order.fire_events(pay_manner.code).should be_false
        end

        describe do
          before do
            @order.buyer_fire_event!(:buy)
          end

          it "等待发货 到 等待签收" do
            @order.state.should eq("waiting_delivery")
            @order.seller_fire_event!("delivered")
            @order.state.should eq("waiting_sign")
          end

          describe do
            before do
              @order.seller_fire_event!("delivered")
            end

            it "等待签收 到 完成" do
              @order.state.should eq("waiting_sign")
              @order.buyer_fire_event!(:sign)
              @order.state.should eq("complete")
            end
          end
        end
      end
    end
  end

  describe "实例方法" do
    let(:items){ [item_1, item_2].map{|item| item.attributes.symbolize_keys! } }

    before do
      @order = generate_order
    end

    describe "build_items" do
      it "批量建立订单产品" do
        order = OrderTransaction.new
        expect { order.build_items(items) }.to change { order.items.size }.by(2)
      end
    end

    describe "update_total_count" do
      it "计算产品数" do
        count_sum = items.reduce(0) { |s, i| s + i[:amount] }
        expect { @order.update_total_count }.to change { @order.items_count }.by(count_sum)
      end

      it "总金额" do
        total_sum = items.reduce(0) { |s, i| s + i[:total] }
        expect { @order.update_total_count }.to change { @order.total }.by(total_sum)
      end
    end


    describe "get_delivery_price" do
      it "获取运输费用" do
        order = generate_order
        prices = []
        order.items.map do |item|
          prices << rand(10)
          ProductDeliveryType.create(
            :delivery_price => prices.last,
            :delivery_type_id => ems.id,
            :product_id => item.product_id)
        end
        order.get_delivery_price(ems.id).should eq(prices.max)
      end
    end

    describe "模型装饰" do
      it "模型装饰  total " do
        pr = generate_order
        pr_de = pr.decorate
        pr_de.source.total.should eq(pr_de.total.delete(', ¥$').to_f)
      end
    end
  end

end