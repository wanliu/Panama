class People::CommunitiesController < People::BaseController

  def index
  end

  def show
    @circle = Circle.find_by(:id => params[:id])
    respond_to do |format|
      format.html{ render :layout => "circles" }
    end
  end

  def create
  	@setting = CircleSetting.create(params[:setting])
  	@people.circles.create(params[:circle],:setting_id => @setting.id)

  	respond_to do |format|
  		format.html { redirect_to person_circles_path(@people) }
      format.json { head :no_content }
  	end
  end
end