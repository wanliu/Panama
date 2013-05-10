class ReceiveOrderMessagesController < ApplicationController
  before_filter :login_required

  def create
    @transaction = current_user.transactions.find_by(:id => params[:transaction_id])
    @message = @transaction.message_create(
      params[:message].merge(:send_user => current_user))

    render :partial => "transactions/_message", :locals => {
     :message => @message}
  end

end