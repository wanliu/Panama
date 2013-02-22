class RealtimeNoticeController < FayeRails::Controller

  observe OrderTransaction, :after_create do |new_transaction|
    RealtimeNoticeController.publish '/notice/transactions', new_transaction.attributes
  end 
end