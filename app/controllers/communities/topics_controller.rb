#encoding: utf-8
class Communities::TopicsController < Communities::BaseController
  before_filter :require_member

  def create
    attachment_ids = params[:topic][:attachment_ids]
    params[:topic].delete(:attachment_ids)
    @topic = @circle.topics.create(params[:topic].merge({ :user => current_user }))
    if attachment_ids.present?
      @topic.attachments = attachment_ids.map do |k, v| Attachment.find(v.to_i) end
    end

    respond_to do |format|
      if @topic.valid?
        format.json{ render :json => @topic.as_json(
          :methods => [:comments_count, :top_comments]) }
      else
        format.json{ render :json => draw_errors_message(@topic), :status => 403 }
      end
    end
  end

  def index
    @topics = @circle.topics.order("created_at desc").offset(params[:offset]).limit(params[:limit])
    respond_to do |format|
      format.json{ render :json => @topics.as_json(
        :methods => [:comments_count, :top_comments]) }
    end
  end

  def create_comment
    @topic = @circle.topics.find_by(:id => params[:id])
    respond_to do |format|
      if @circle.is_member?(current_user.id)
        @comment = @topic.comments.create(params[:comment].merge(:user_id => current_user.id))
        if @comment.valid?
          format.json{ render :json => @comment }
        else
          format.json{ render :json => draw_errors_message(@comment), :status => 403 }
        end
      else
        format.json{ render :json => ["你没有回复的权限, 加入商圈"], :status => 403 }
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