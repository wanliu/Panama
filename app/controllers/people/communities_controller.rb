#encoding: utf-8
class People::CommunitiesController < People::BaseController

  def index
  end

  def show
    @circle = Circle.find_by(:id => params[:id])
    respond_to do |format|
      format.html{ render :layout => "circles" }
    end
  end

  def all_circles
    @circles = @people.all_circles
    respond_to do |format|
      format.html{ render :layout => false }
      format.dialog{ render :layout => false }
    end
  end

  def create
  	@setting = CircleSetting.create(params[:setting])
    params[:circle].merge!(:setting_id => @setting.id)
  	@circle = @people.circles.create(params[:circle])
    CircleCategory.create(:name => "分享", :circle_id => @circle.id)

  	respond_to do |format|
  		format.html { redirect_to person_circles_path(@people) }
      format.json { head :no_content }
  	end
  end


end