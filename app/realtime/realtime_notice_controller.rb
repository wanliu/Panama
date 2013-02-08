class RealtimeNoticeController < FayeRails::Controller

  observe Transaction, :after_create do |new_transaction|
    debugger
    RealtimeNoticeController.publish '/notice/transactions', new_transaction.attributes
  end 
end