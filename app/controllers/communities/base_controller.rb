class Communities::BaseController < ApplicationController
  layout "circles"

  before_filter :identity

  def identity
    @circle = Circle.find_by(:id => params[:community_id])
    redirect_to root_url if @circle.nil?
  end
end