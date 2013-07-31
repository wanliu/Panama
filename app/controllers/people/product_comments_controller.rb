class People::ProductCommentsController < People::BaseController
	before_filter :login_required

	def index
		@transactions = current_user.transactions.where(:state => "complete")
	end

  def order
    @transaction = current_user.transactions.where(:state => "complete").find(params[:order_id])
  end

  def create
    content = params[:product_comment].delete(:content)
    product_item_id = params[:product_comment].delete(:product_item_id)
    @item = ProductItem.find_by(:id => product_item_id, :user_id => current_user.id)

    respond_to do |format|
      if @item.product_comment.nil?
        @product_comment = ProductComment.new(params[:product_comment].merge(product_item: @item))
        if @product_comment.save
          @comment = @product_comment.comments.create(
            :content => content, :user_id => current_user.id)
          format.json{ render :json => @comment  }
        else
          format.json{ render :json => draw_errors_message(@product_comment), :status => 403 }
        end
      else
        @comment = @item.product_comment.comments.create(
          :content => content, :user_id => current_user.id)
        format.json{ render :json => @comment  }
      end
    end
  end
end
