class People::Comments < People::BaseController

    def index
        @comments = Comment.where(:product_id => params[:product_id])
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

    def create
        @comment = Comment.new(params[:comment])
        if @comment.save
            render :action => :show
        else
            render :action => :edit
        end
    end

    def update
        @comment = Comment.find(params[:id])
        @comment.update_attribute(params[:comment])
        if @comment.save
            render :action => :show
        else
            render :action => :edit
        end
    end
end