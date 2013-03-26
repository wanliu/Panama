class Admins::Shops::CirclesController < Admins::Shops::SectionController

  def index
    @circles = current_shop.circles
    respond_to do |format|
      format.html
      format.json{ render json: @circles.as_json(methods: :friend_count) }
    end
  end

  def create
    @circle = current_shop.circles.create(params[:circle])
    respond_to do |format|
      if @circle.valid?
        format.html
        format.json{ render json: @circle }
      else
        format.json{ render json: draw_errors_message(@circle), status: 403 }
      end
    end
  end

end