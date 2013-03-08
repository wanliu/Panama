class PeopleController < ApplicationController
  # before_filter :login_required, :only => [:invite]

  layout "people"

  def show
    @people = User.find_by(:login => params[:id])
  end

  def invite

  end
end
