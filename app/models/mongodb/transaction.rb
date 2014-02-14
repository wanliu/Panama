# 交易模型
#
# 交易状态转换表
#
#
#        下单 | 等待付款 | 预付 | 等待出货 | 未出 | 到达 | 未到 | 客户确认 | 未确认 | 退货
#   显示
#   退款    -    -     y     y      y
#   评价
#
class Mongodb::Transaction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :state, :type => String
  field :items_count, :type => Fixnum
  field :total, :type => BigDecimal

  has_one :address

  belongs_to :seller, inverse_of: :transactions, class_name: "Shop"
  belongs_to :buyer, inverse_of: :transactions, class_name: "User"

  has_many :items, inverse_of: :transaction, class_name: "ProductItem",  autosave: true

  state_machine :initial => :order do

    event :buy do
      transition [:order] => :waiting_paid
    end

    event :back do
      transition [:waiting_paid] => :order
    end
  end
end
