class ContactFriendsController < ApplicationController
  before_filter :login_required

  def index
    @friends = current_user.contact_friends.joins(:friend)
    .order("last_contact_date desc").limit(10).reverse
    respond_to do |format|
      format.json{ render :json => @friends }
    end
  end

  def join_friend
    @contact_friend = current_user.contact_friends
    .join_friend(params[:friend_id])
    respond_to do |format|
      if @contact_friend.valid?
        format.json{ render :json => @contact_friend }
      else
        format.json{ render :json => draw_errors_message(@contact_friend), :status => 403 }
      end
    end
  end

  def destroy
    # current_user.contact_friends.find()
  end
end