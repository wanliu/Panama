#encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :online_payment, :class => PayManner do
    name "在线支付"
    code 'online_payment'
    description "即时到帐，支持绝大数银行借记卡及部分银行信用卡"
  end

  factory :cash_on_delivery, :class => PayManner do
  	name '货到付款'
  	code 'cash_on_delivery'
  	description "配送员将商品送到时支付"
  	default_state true
  end

  factory :bank_transfer, :class => PayManner do
  	name "银行汇款"
  	code "bank_transfer"
  	description "通过快钱平台收款 汇款后1-3个工作日到账"
  end
end
