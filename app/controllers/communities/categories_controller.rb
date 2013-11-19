class Communities::CategoriesController < Communities::BaseController
  before_filter :validate_manager, :only => [:create, :update, :destroy]
  before_filter :require_member

  def index
  end

  def show
    @category = @circle.categories.find(params[:id])
    respond_to do |format|
      format.html
      format.json{ render json: @category }
    end
  end

  def topics
    @category = @circle.categories.find(params[:id])
    @topics = @category.topics.order("created_at desc").limit(params[:limit]).offset(params[:offset])
    respond_to do |format|
      format.json{ render json:  @topics }
    end
  end

  def category
    @category = CircleCategory.find(params[:category_id])
    respond_to do |format|
      format.html
      format.json{ render json: @topics }
    end
  end

  def create
    @category = @circle.categories.only_deleted.find_by(:name => params[:name])
    if @category.nil?
      @category = @circle.categories.create(:name => params[:name])
    else
      @category.recover
    end
    respond_to do |format|
      if @category.valid?
        format.html
        format.json{ render json: @category }
      else
        format.json{ render json: draw_errors_message(@category), status: 403 }
      end
    end
  end

  def update
    @circle_category = @circle.categories.find(params[:id])
    @circle_category.update_attributes(:name => params[:name])
    respond_to do |format|
      format.html
      format.json{ render json: @circle_category }
    end
  end

  def destroy
    @circle.categories.find(params[:id]).destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end
  private
  def validate_manager
    unless @circle.is_manage?(current_user.id)
      respond_to do |format|
        format.json{ render json: draw_errors_message(@category), status: 403 }
      end
    end
  end
end