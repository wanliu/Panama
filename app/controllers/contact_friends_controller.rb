class ContactFriendsController < ApplicationController
  before_filter :login_and_service_required

  def index
    @friends = current_user.contact_friends.joins(:friend)
    .order("last_contact_date desc").limit(10)
    respond_to do |format|
      format.json{ render :json => @friends }
    end
  end

end