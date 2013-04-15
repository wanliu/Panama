#describe: 评论控制器
class CommentsController < ApplicationController
  before_filter :login_required, :only => [:activity, :product]

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

  def show
    @comment = Comment.find(params[:id])
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  #活动评论
  def activity
    authorize! :activity, Comment
    @comment = Comment.activity(params[:comment].merge(:user_id => current_user.id))
    users = @comment.content_extract_users
    users.each do |user|
        @comment.content = @comment.content.gsub(/@#{user.login}/,
            "<a href='#'>@#{user.login}</a>")
    end
    @comment.save
    respond_to do |format|
        if @comment.valid?
            format.html { render :action => :show }
            format.js { render :json => @comment.as_json.merge(@comment.user.as_json) }
        else
            render :action => :edit
        end
    end
  end

  #产品评论
  def product
    authorize! :product, Comment
    @comment = Comment.product(params[:comment].merge(:user_id => current_user.id))
    if @comment.valid?
      render :action => :show
    else
      render :action => :edit
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