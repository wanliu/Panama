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
    @message = current_user.chat_messages.create(params[:chat_message])
    respond_to do |format|
      if @message.valid?
        format.json{ render :json => @message }
      else
        format.json{ render :json => draw_errors_message(@message), :status => 403 }
      end
    end
  end

  def dialogue
    @friend = User.find(params[:friend_id])
    respond_to do |format|
      format.html
    end
  end

  def read
    @message = current_user.receive_messages.find(params[:id])
    @message.change_state
    respond_to do |format|
      format.json{ render :json => @message }
    end
  end
end