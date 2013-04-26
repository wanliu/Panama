#encoding: utf-8
class ChatMessagesController < ApplicationController
  before_filter :login_required

  def index
    @messages = current_user.messages(params[:friend_id])
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
end