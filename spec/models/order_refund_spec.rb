#encoding: utf-8
require 'spec_helper'

describe OrderRefund, "退货模型" do

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
  let(:icbc){ FactoryGirl.create(:icbc) }
  let(:order_reason){ FactoryGirl.create(:order_reason) }
  let(:delivery_manner){ FactoryGirl.create(:express) }
  let(:pay_manner){ FactoryGirl.create(:online_payment) }

  describe "关联检查" do
    it{ should belong_to(:order_reason) }
    it{ should belong_to(:order_transaction) }
    it{ should belong_to(:buyer) }
    it{ should belong_to(:seller) }
    it{ should belong_to(:operator) }

    it{ should have_many(:items) }
    it{ should have_many(:state_details) }

    it{ should validate_presence_of(:order_reason) }
    it{ should validate_presence_of(:order_transaction) }
  end

  def generate_order
    item_1.cart = my_cart
    item_2.cart = my_cart

    item_1.save
    item_2.save

    my_cart.create_transaction(current_user)
    OrderTransaction.last
  end

  def generate_refund(order, items)
    refund = order.refunds.create(
      :descripton => '退货',
      :order_reason_id => order_reason.id)
    refund.create_items(items)
    refund
  end

  describe "状态" do

    def refund_order
      order = generate_order
      order.address = current_user_address
      order.delivery_type = ems
      order.pay_manner = pay_manner
      order.delivery_manner = delivery_manner
      order.buyer_fire_event!(:buy)
      order.buyer.recharge(order.stotal, cbc)
      order.buyer_fire_event!(:paid)
      order
    end

    def now_expire(detail)
      detail.expired = DateTime.now
      detail.save
    end

    describe "订单还未发货" do
      before do
        @order = refund_order
        @refund = generate_refund(@order, @order.items.map{|item| item.id })
      end

      it "申请退货 到 退货失败" do
        @refund.state.should eq("apply_refund")
        @refund.refuse_reason = "无理由退货"
        @refund.seller_fire_events!("refuse")
        @refund.state.should eq("failure")
      end

      it "申请退货 状态过期" do
        now_expire(@refund.current_state_detail)
        OrderRefund.state_expired
        @refund.reload.state.should eq("apply_failure")
      end

      it "拒绝退货 变更状态明细" do
        size = @refund.state_details.count

        @refund.refuse_reason = "无理由退货"
        @refund.seller_fire_events!("refuse")
        @refund.current_state_detail.state.should eq("failure")
        @refund.state_details.count.should eq(size+1)
      end

      it "申请退货 到 成功" do
        @refund.state.should eq("apply_refund")
        @refund.seller_fire_events!("unshipped_agree")
        @refund.state.should eq("complete")
      end

      it "接受退货 变更状态明细" do
        size = @refund.state_details.count

        @refund.seller_fire_events!("unshipped_agree")
        @refund.current_state_detail.state.should eq("complete")
        @refund.state_details.count.should eq(size+1)
      end

      it "成功返还金额给买家" do
        money = @refund.buyer.money
        @refund.seller_fire_events!("unshipped_agree")
        @refund.buyer.money.should eq(money+@refund.stotal)
      end
    end

    describe "订单已经发货" do
      before do
        @order = refund_order
        @order.delivery_code = "87986545"
        @order.seller_fire_event!(:delivered)
        @refund = generate_refund(@order, @order.items.map{|item| item.id })
      end

      it "申请退货 到 拒绝" do
        @refund.state.should eq("apply_refund")
        @refund.refuse_reason = "无理由退货"
        @refund.seller_fire_events!("refuse")
        @refund.state.should eq("failure")
      end

      it "拒绝退货 变更状态明细" do
        size = @refund.state_details.count

        @refund.refuse_reason = "无理由退货"
        @refund.seller_fire_events!("refuse")
        @refund.current_state_detail.state.should eq("failure")
        @refund.state_details.count.should eq(size+1)
      end

      it "申请退货 状态过期" do
        now_expire(@refund.current_state_detail)
        OrderRefund.state_expired
        @refund.reload.state.should eq("apply_failure")
      end

      it "申请退货 到 等待发货" do
        @refund.state.should eq("apply_refund")
        @refund.seller_fire_events!("shipped_agree")
        @refund.state.should eq("waiting_delivery")
      end

      it "接受退货 变更状态明细" do
        size = @refund.state_details.count

        @refund.seller_fire_events!("shipped_agree")
        @refund.current_state_detail.state.should eq("waiting_delivery")
        @refund.state_details.count.should eq(size+1)
      end

      describe do
        before do
          @refund.seller_fire_events!("shipped_agree")
        end

        it "等待发货 到 等待签收" do
          @refund.state.should eq("waiting_delivery")
          @refund.delivery_code = "8489489489"
          @refund.buyer_fire_events!("delivered")
          @refund.state.should eq("waiting_sign")
        end

        it "等待发货 状态过期" do
          now_expire(@refund.current_state_detail)
          OrderRefund.state_expired
          @refund.reload.state.should eq("close")
        end

        it "接受退货 变更状态明细" do
          size = @refund.state_details.count

          @refund.delivery_code = "8489489489"
          @refund.buyer_fire_events!("delivered")
          @refund.current_state_detail.state.should eq("waiting_sign")
          @refund.state_details.count.should eq(size+1)
        end

        describe do
          before do
            @refund.delivery_code = "8489489489"
            @refund.buyer_fire_events!("delivered")
          end

          it "等待签收 到 完成" do
            @refund.state.should eq("waiting_sign")
            @refund.seller_fire_events!("sign")
            @refund.state.should eq("complete")
          end

          it "等待签收 状态过期" do
            now_expire(@refund.current_state_detail)
            OrderRefund.state_expired
            @refund.reload.state.should eq("complete")
          end

          it "完成 变更状态明细" do
            size = @refund.state_details.count

            @refund.seller_fire_events!("sign")
            @refund.current_state_detail.state.should eq("complete")
            @refund.state_details.count.should eq(size+1)
          end

          it "订单还未完成，只是付款 退还金额给买家一方" do
            money = @refund.buyer.money
            expect{
              @refund.seller_fire_events!("sign")
            }.to change{ @refund.buyer.money }.by(money + @refund.stotal)
          end

          it "订单完成，退还金额给双方" do
            @refund.order_transaction.buyer_fire_event!("sign")
            bmoney = @refund.buyer.money
            smoney = @refund.seller.user.money

            @refund.seller_fire_events!("sign")
            @refund.buyer.money.should eq(bmoney + @refund.stotal)
            @refund.seller.user.money.should eq(smoney - @refund.stotal)
          end
        end
      end
    end
  end

  describe "change_order_state" do

    it "变更订单状态" do

    end
  end

end
