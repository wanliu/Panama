class Communities::CategoriesController < Communities::BaseController

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

end