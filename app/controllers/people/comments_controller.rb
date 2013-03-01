class People::CommentsController < People::BaseController

    def index_activities

    end

    def index
        @activities = Activity.all
        @comment = Comment.new
    end

    def show
        @comment = Comment.find(params[:id])
    end

    def new_activity
        @comment = Comment.new
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
        if @comment.valid?
            render :action => :show
        else
            render :action => :edit
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