class ContactFriendsController < ApplicationController
  before_filter :login_required

  def index
    @friends = current_user.contact_friends.joins(:friend)
    .order("last_contact_date desc").limit(10).reverse
    respond_to do |format|
      format.json{ render :json => @friends.as_json(:include =>friend) }
    end
  end

  # def create
  #   @contact_friend = current_user.contact_friends
  #   .join_friend(:friend_id => params[:friend_id])
  #   respond_to do |format|
  #     format.json{ render :json => @contact_friend.friend }
  #   end
  # end

  def join_friend
    @contact_friend = current_user.contact_friends
    .join_friend(:friend_id => params[:friend_id])
    respond_to do |format|
      format.json{ render :json => @contact_friend.friend }
    end
  end
end