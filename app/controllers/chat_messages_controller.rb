#encoding: utf-8
class ChatMessagesController < ApplicationController
  before_filter :login_and_service_required

  def index
    @messages = current_user.chat_messages.order("created_at desc").limit(30)

    @messages.where(
      :send_user_id => params[:friend_id],
      :receive_user_id => current_user.id
    ).update_all(read: true)

    ChatMessage.notice_read_state(current_user, params[:friend_id])

    respond_to do |format|
      format.json{ render :json => @messages.reverse }
    end
  end

  def create
    receive_user = User.find(params[:chat_message].delete(:receive_user_id))
    @message = current_user.chat_messages.create(
      params[:chat_message].merge(:send_user => current_user, :receive_user => receive_user))

    respond_to do |format|
      if @message.valid?
        format.json{ render :json => @message }
      else
        format.json{ render :json => draw_errors_message(@message), :status => 403 }
      end
    end
  end

  def display
    @dialogue = Dialogue.display(params[:token], current_user.id)
    respond_to do |format|
      format.html
    end
  end

  #聊天框
  def generate
    @dialogue = Dialogue.generate(params[:friend_id], current_user.id)
    respond_to do |format|
      format.json{ render :json => @dialogue }
    end
  end

  # 合二为一
  def generate_and_display
    token     = Dialogue.generate(params[:friend_id], current_user.id).token
    @dialogue = Dialogue.display(token, current_user.id)
    @dialogue_id = params[:friend_id]
    render action: :display
  end

  #读取信息通知
  def read
    @messages = current_user.chat_messages.unread.where(send_user_id: params[:friend_id])
    @messages.update_all(read: true)

    ChatMessage.notice_read_state(current_user, params[:friend_id])
    respond_to do |format|
      format.json{ render :json => @messages }
    end
  end
end