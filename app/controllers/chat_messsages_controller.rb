#encoding: utf-8
class ChatMessagesController < ApplicationController
  before_filter :login_required

  def index
    # current_user
  end

  def create
    @message = current_user.chat_messages.create(params[:message])
    respond_to do |format|
      if @message.valid?
        format.json{ render :json => @messages }
      else
        format.json{ render :json =>draw_errors_message(@message), :status => 403 }
      end
    end
  end

  def dialogue
    @friend = current_user.contact_friends.find(friend_id: params[:friend_id])
    @messages = current_user.chat_messages
    .where(friend_id: params[:friend_id])
    respond_to do |format|
      format.json{ render :json => @messages }
    end
  end
end