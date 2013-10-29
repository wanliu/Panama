class People::CommunitiesController < People::BaseController

  def index
  end

  def show
    @circle = Circle.find_by(:id => params[:id])
    respond_to do |format|
      format.html{ render :layout => "circles" }
    end
  end
end