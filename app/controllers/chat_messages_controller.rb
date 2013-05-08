#encoding: utf-8
class ChatMessagesController < ApplicationController
  before_filter :login_required

  def index
    @messages = current_user.messages(params[:friend_id])

    @messages.where(
      :send_user_id => params[:friend_id],
      :receive_user_id => current_user.id
    ).update_all(read: true)

    ChatMessage.notice_read_state(current_user, params[:friend_id])
    respond_to do |format|
      format.json{ render :json => @messages }
    end
  end

  def create
    receive_user = User.find(params[:chat_message].delete(:receive_user_id))
    @message = current_user.chat_messages.create(
      params[:chat_message].merge(receive_user: receive_user))

    respond_to do |format|
      if @message.valid?
        format.json{ render :json => @message }
      else
        format.json{ render :json => draw_errors_message(@message), :status => 403 }
      end
    end
  end

  #聊天框
  def dialogue
    @friend = User.find(params[:friend_id])
    respond_to do |format|
      format.html
    end
  end

  #交易聊天框
  def transaction_dialogue
    @transaction = OrderTransaction.find(params[:transaction_id])
    respond_to do |format|
      format.html
    end
  end

  #读取信息通知
  def read
    @messages = current_user.receive_messages.unread
    .where(send_user_id: params[:friend_id])
    @messages.update_all(read: true)

    ChatMessage.notice_read_state(current_user, params[:friend_id])
    respond_to do |format|
      format.json{ render :json => @messages }
    end
  end
end