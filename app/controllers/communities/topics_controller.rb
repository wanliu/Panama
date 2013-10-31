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
    @topics = @circle.topics.order("created_at desc")
    respond_to do |format|
      format.json{ render :json => @topics }
    end
  end

  def init_comment
    @topic = @circle.topics.find_by(:id => params[:id])
    @comments = @topic.comments.order("created_at desc").limit(3)
    respond_to do |format|
      format.json{ render :json => {
        comments: @comments,
        count: @topic.comments.count} }
    end
  end

  def create_comment
    @topic = @circle.topics.find_by(:id => params[:id])
    @comment = @topic.comments.create(params[:comment].merge(:user_id => current_user.id))
    respond_to do |format|
      if @comment.valid?
        format.json{ render :json => @comment }
      else
        format.json{ render :json => draw_errors_message(@comment), :status => 403 }
      end
    end
  end

  def comments
    @topic = @circle.topics.find_by(:id => params[:id])
    @comments = @topic.comments.order("created_at desc")
    respond_to do |format|
      format.json{ render :json => @comments }
    end
  end

  def participate
    @topic = @circle.topics.find_by(:id => params[:id])
    @participate = @topic.participates.create(user_id: current_user.id)
    respond_to do |format|
      if @participate.valid?
        format.json{ render :json => @participate.user }
      else
        format.json{ render :json => draw_errors_message(@participate) , :status => 403 }
      end
    end
  end

  def participates
    @topic = @circle.topics.find_by(:id => params[:id])
    @users = @topic.participates.joins(:user).order("created_at desc")
    .limit(10).map{|p| p.user}
    respond_to do |format|
      format.json{ render :json => @users }
    end
  end

end