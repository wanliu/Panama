class Communities::BaseController < ApplicationController
  layout "circles"

  include CommunitiesHelper

  before_filter :identity

  def identity
    @circle = Circle.find_by(:id => params[:community_id])
    if @circle.nil?
      redirect_to root_url
    else
      if @circle.limit_join?
        unless access_denied? || except_denied?([:apply_join])
          unless @circle.is_member?(current_user.id)
            redirect_to community_access_denied_path(@circle)
            return
          end
        end
      end

      if access_denied?
        if @circle.is_member?(current_user.id)
          redirect_to community_circles_path(@circle)
        end
      end
    end
  end
end