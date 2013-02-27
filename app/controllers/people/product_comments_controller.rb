class People::ProductComments < People::BaseController

    def index
        @product_comments = ProductComment.where(:product_id => params[:product_id])
    end

    def show
        @product_comment = ProductComment.find(params[:id])
    end

    def new
        @product_comment = ProductComment.new
    end

    def edit
        @product_comment = ProductComment.find(params[:id])
    end

    def create
        @product_comment = ProductComment.new(params[:product_comment])
        if @product_comment.save
            render :action => :show
        else
            render :action => :edit
        end
    end

    def update
        @product_comment = ProductComment.find(params[:id])
        @product_comment.update_attribute(params[:product_comment])
        if @product_comment.save
            render :action => :show
        else
            render :action => :edit
        end
    end
end