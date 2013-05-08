class ReceiveOrderMessage < ActiveRecord::Base
  attr_accessible :message, :order_transaction_id, :send_user_id, :state
end
