class People::CirclesController < People::BaseController

  def index
    @circles = @people.circles
    respond_to do |format|
      format.json{ render :json => @circles }
    end
  end

  def create
    @circle = @people.circles.create(params[:circle])
    respond_to do |format|
      if @circle.valid?
        format.json{ render json: @circle }
      else
        format.json{ render json: draw_errors_message(@circle), status: 403 }
      end
    end
  end

  def show
    @circles = @people.circles
    @circle = @people.circles.find(params[:id])
    respond_to do |format|
      format.json{ render json: @circle }
    end
  end

end