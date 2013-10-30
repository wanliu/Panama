class Communities::TopicsController < Communities::BaseController

  def create
    @topic = @circle.topics.create(params[:topic].merge({
      :user => current_user}))
    respond_to do |format|
      if @topic.valid?
        format.json{ render :json => @topic }
      else
        format.json{ render :json => draw_errors_message(@topic), :status => 403 }
      end
    end
  end

  def index
    @topics = @circle.topics
    respond_to do |format|
      format.json{ render :json => @topics }
    end
  end

end