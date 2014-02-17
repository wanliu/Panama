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
  let(:order_reason){ FactoryGirl.create(:order_reason) }

  it{ should belong_to(:address) }
  it{ should belong_to(:seller) }
  it{ should belong_to(:buyer) }
  it{ should have_many(:items) }
  it{ should have_one(:transfer_sheet) }
  it{ should belong_to(:pay_manner) }
  it{ should belong_to(:delivery_manner) }
  it{ should belong_to(:operator) }

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

    def now_expired_state(detail)
      detail.update_attributes(expired: DateTime.now)
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
          count = @order.state_details.count

          @order.state.should eq("order")
          @order.buyer_fire_event!(:buy)
          @order.state.should eq("waiting_paid")
          @order.current_state_detail.state.should eq("waiting_paid")
          @order.state_details.count.should eq(count+1)
        end

        it "状态变更产生状态明细" do
          @order.buyer_fire_event!(:buy)
          @order.state.should eq(@order.state_details.last.state)
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

        it "状态还未过期" do
          OrderTransaction.state_expired
          @order.state.should eq("order")
        end

        it "状态过期" do
          @order.state.should eq("order")
          now_expired_state(@order.state_details.last)
          OrderTransaction.state_expired
          @order.reload.state.should eq("close")
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
            count = @order.state_details.count

            @order.buyer.recharge(@order.stotal, icbc)
            @order.state.should eq("waiting_paid")
            @order.buyer_fire_event!(:paid)
            @order.state.should eq("waiting_delivery")
            @order.current_state_detail.state.should eq("waiting_delivery")
            @order.state_details.count.should eq(count+1)
            @order.buyer.money.should eq(0.to_d)
          end

          it "状态变更产生状态明细" do
            @order.buyer.recharge(@order.stotal, icbc)
            @order.buyer_fire_event!(:paid)
            @order.state.should eq(@order.state_details.last.state)
          end

          it "状态还未过期" do
            OrderTransaction.state_expired
            @order.state.should eq("waiting_paid")
          end

          it "状态过期" do
            @order.state.should eq("waiting_paid")
            now_expired_state(@order.state_details.last)
            OrderTransaction.state_expired
            @order.reload.state.should eq("close")
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

            it "状态变更产生状态明细" do
              @order.buyer_fire_event!(:delivered)
              @order.state.should eq(@order.state_details.last.state)
            end

            it "状态还未过期" do
              OrderTransaction.state_expired
              @order.state.should eq("waiting_delivery")
            end

            it "状态过期" do
              @order.state.should eq("waiting_delivery")
              now_expired_state(@order.state_details.last)
              OrderTransaction.state_expired
              @order.reload.state.should eq("delivery_failure")
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

              it "状态变更产生状态明细" do
                @order.buyer_fire_event!(:sign)
                @order.state.should eq(@order.state_details.last.state)
              end

              it "状态还未过期" do
                OrderTransaction.state_expired
                @order.state.should eq("waiting_sign")
              end

              it "状态过期" do
                @order.state.should eq("waiting_sign")
                now_expired_state(@order.state_details.last)
                OrderTransaction.state_expired
                @order.reload.state.should eq("complete")
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
              @refund = @order.refunds.create(
                :descripton => '退货',
                :order_reason_id => order_reason.id)
              @refund.create_items([@order.items[0].id])
            end

            it "判断是否及时退货" do
              @order.should_receive("unshipped_state?").and_return(true)
              @order.refund_handle_detail_return_money(@refund)
            end

            it "删除明细" do
              @order.items.find_by(
                :product_id => @refund.items.map{|i| i.product_id}
              ).should_not be_nil
              @order.refund_handle_detail_return_money(@refund)
              @order.items.find_by(
                :product_id => @refund.items.map{|i| i.product_id}
              ).should be_nil
            end

            it "返回钱给买家" do
              expect{
                @order.refund_handle_detail_return_money(@refund)
              }.to change{ @order.buyer.money }.by(@refund.stotal)

            end
          end

          describe "refund_handle_product_item" do
            before do
              @refund = @order.refunds.create(
                :descripton => '退货',
                :order_reason_id => order_reason.id)
              @refund.create_items([@order.items[0].id])
            end

            it "标识退货商品" do
              order_refund.should eq(0)
              @order.refund_handle_product_item(@refund)
              order_refund.should eq(1)
            end

            def order_refund
              @order.items.where(
                :refund_state => false).count
            end
          end

          describe "get_refund_items" do
            before do
              @refund = @order.refunds.create(
                :descripton => '退货',
                :order_reason_id => order_reason.id)
              @refund.create_items([@order.items[0].id])
            end

            it "获取订单退货的商品" do
              items = @order.get_refund_items(@refund)
              items.should eq(@order.items.where(:product_id => @refund.items.map{|i| i.product_id}))
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
      it "批量建立订单商品" do
        order = OrderTransaction.new
        expect { order.build_items(items) }.to change { order.items.size }.by(2)
      end
    end

    describe "update_total_count" do
      before do
        @order.build_items(items)
      end
      it "计算商品数" do
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

    it "付款后的订单状态" do
      @order.state = "waiting_sign"
      @order.shipped_state?.should be_true
      @order.state = "complete"
      @order.shipped_state?.should be_true
    end

    it "没有付款的订单状态" do
      @order.state = "delivery_failure"
      @order.unshipped_state?.should be_true
      @order.state = "waiting_delivery"
      @order.unshipped_state?.should be_true
    end

    it "是否成功状态" do
      @order.complete_state?.should be_false
      @order.state = "complete"
      @order.complete_state?.should be_true
    end

    it "是否退货状态" do
      @order.refund_state?.should be_false
      @order.state = "refund"
      @order.refund_state?.should be_true
    end

    it "等待退货状态" do
      @order.wating_refund_state?.should be_false
      @order.state = "waiting_refund"
      @order.wating_refund_state?.should be_true
    end

    describe "buyer_payment" do
      it "买家付款" do
        expect{
          @order.buyer_payment
        }.to change{ @order.buyer.money }.by(@order.buyer.money - @order.stotal)
      end
    end

    describe "seller_recharge" do
      it "卖家收款" do
        expect{
          @order.seller_recharge
        }.to change{ @order.seller.user.money }.by(@order.stotal)
      end
    end

    describe "state_change_detail" do
      before do
        @order = generate_order
      end

      it "初始化订单，产生状态" do
        OrderTransaction.any_instance.should_receive(:state_change_detail)
        generate_order
      end

      it "添加状态明细记录" do
        @order.state_details.destroy_all
        expect{
          @order.state_change_detail
        }.to change(TransactionStateDetail, :count).by(1)
      end
    end
  end

  describe "类方法" do
  end

end