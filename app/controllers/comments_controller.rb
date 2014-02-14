#describe: 评论控制器
class CommentsController < ApplicationController
  before_filter :login_and_service_required, :only => [:activity, :product, :topic, :update, :destroy]

  def index_activities
    @activities = Activity.all
  end

  def index
    @comments = Comment.where("targeable_id=? and targeable_type=?",
        params[:targeable_id],
        params[:targeable_type])
    if params[:limit]
      @comments = @comments.order("created_at desc").limit(params[:limit]).reverse()
    end
    respond_to do | format |
      format.json{ render json: @comments }
      format.html
    end
  end

  def count
    @count = Comment.where("targeable_id=? and targeable_type=?",
        params[:targeable_id],
        params[:targeable_type]).count
    respond_to do | format |
      format.json{ render json: @count }
    end
  end

  #活动评论
  def activity
    @comment = Comment.activity(params[:comment].merge(:user_id => current_user.id))
    respond_to do |format|
      if @comment.valid?
        format.js { render :json => @comment.as_json.merge(@comment.user.as_json) }
      else
        format.js{ render :json => {}, :status => 403 }
      end
    end
  end

  #商品评论
  def product
    @comment = Comment.product(params[:comment].merge(:user_id => current_user.id))
    respond_to do |format|
      if @comment.valid?
        format.json{ render json: @comment }
      else
        format.json{ render json: draw_errors_message(@comment), status: 403 }
      end
    end
  end

  #帖子评论
  def topic
    option = params[:comment].merge(user_id: current_user.id)
    @comment = Comment.topic(option)
    respond_to do |format|
      format.json{ render json: @comment }
    end
  end

  def update
    @comment = Comment.find_by(id: params[:id], user_id: current_user.id)
    respond_to do |format|
      if @comment.update_attributes(content: params[:content])
        format.json{ render json: @comment  }
      else
        format.json{ render json: draw_errors_message(@comment), status: 403  }
      end
    end
  end

  def destroy
    @comment = Comment.find_by(id: params[:id], user_id: current_user.id)
    @comment.destroy
    respond_to do |format|
      format.json{ head :no_content }
    end
  end
end