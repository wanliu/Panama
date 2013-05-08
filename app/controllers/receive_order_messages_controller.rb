class ReceiveOrderMessagesController < ApplicationController
  before_filter :login_required

  def create
    @transaction = current_user.transactions.find_by(:id => params[:message][:transaction_id])
    @message = @transaction.message_create(
      params[:message].merge(:send_user => current_user))

    render :partial => "chat_messages/transaction_message", :locals => {
     :message => @message}
  end

end