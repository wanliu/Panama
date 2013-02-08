class PeopleController < ApplicationController
  layout "people"

  def show
    @people = User.find_by(:login => params[:id])
  end
end
