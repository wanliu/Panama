class People::BaseController < ApplicationController

  layout 'people'

  before_filter :identity

  def identity
    @people = User.find_by(:login => params[:person_id])
  end
end