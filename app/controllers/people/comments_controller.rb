class People::CommentsController < People::BaseController

    def index
        @comments = Comment.where("targeable_type=?", params[:targeable_type])
    end

    def show
        @comment = Comment.find(params[:id])
    end

    def new
        @comment = Comment.new
    end

    def edit
        @comment = Comment.find(params[:id])
    end

    #活动评论
    def activity
        @comment = Comment.activity(params[:comment])
        if @comment.valid?
            render :action => :show
        else
            render :action => :edit
        end
    end

    #产品评论
    def product
        @comment = Comment.product(params[:comment])
        if @comment.valid?
            render :action => :show
        else
            render :action => :edit
        end
    end
end