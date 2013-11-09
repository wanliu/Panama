class Communities::BaseController < ApplicationController
  layout "circles"

  include CommunitiesHelper

  before_filter :identity

  def identity
    @circle = Circle.find_by(:id => params[:community_id])
    if @circle.nil?
      redirect_to root_url
    else
      if access_denied?
        if @circle.is_member?(current_user.id)
          redirect_to community_circles_path(@circle)
        end
      end
    end
  end

  def validate_manager
    unless @circle.is_manage?(current_user.id)
      respond_to do |format|
        format.json{ render json: draw_errors_message(@category), status: 403 }
      end
    end
  end

  def require_member
    unless access_denied?
      if @circle.limit_join? || @circle.limit_city?
        unless @circle.is_member?(current_user.id)
          respond_to do |format|
            format.js{ render :js => "window.location.href='#{community_access_denied_path(@circle)}'" }
            format.html{
            redirect_to community_access_denied_path(@circle) }
          end
        end
      end
    end
  end
end