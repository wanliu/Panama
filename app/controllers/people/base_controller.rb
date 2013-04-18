class People::BaseController < ApplicationController

  layout 'people'

  before_filter :identity


  def identity
    @people = User.find_by(:login => params[:person_id] || params[:id])
  end

  def current_ability
    @current_ability ||= PeopleAbility.new(current_user, @people)
  end
end