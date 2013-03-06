class People::CommentsController < People::BaseController

    def index_activities
        @activities = Activity.all
    end

    def index
        @comments = Comment.where("targeable_id=? and targeable_type=?", 
            params[:targeable_id], 
            params[:targeable_type])
        if "0" != params[:limit]
            @comments = @comments.order("created_at desc").limit(params[:limit]).reverse()
        end
        @activity = Activity.find(params[:targeable_id])
        @comment = Comment.new
        respond_to do | format |
            format.html{ render :layout => false }
        end
    end

    def show
        @comment = Comment.find(params[:id])
    end

    def new_activity
        @comment = Comment.new
        @user = User.where("1 = 1")
    end

    def new_product
        @comment = Comment.new
    end

    def edit
        @comment = Comment.find(params[:id])
    end

    #活动评论
    def activity
        @comment = Comment.activity(params[:comment].merge(:user_id => current_user.id))
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
        @comment = Comment.product(params[:comment].merge(:user_id => current_user.id))
        if @comment.valid?
            render :action => :show
        else
            render :action => :edit
        end
    end
end