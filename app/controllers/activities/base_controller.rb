class Activities::BaseController < ApplicationController
  before_filter :login_and_service_required
  before_filter :load_category, :only => [:index, :new, :show]

  # layout "activities"
  layout "stream"

  respond_to :html, :dialog


  def like
    @activity = Activity.find(params[:id])
    @activity.likes.find(current_user)
  rescue ActiveRecord::RecordNotFound
    @activity.likes << current_user
  ensure
    render :text => :OK
  end

  def unlike
    @activity = Activity.find(params[:id])
    @activity.likes.find(current_user)
    @activity.likes.delete(current_user)
    render :text => :OK
  end

end