class People::ProductCommentsController < People::BaseController
	before_filter :login_and_service_required

	def index
		@transactions = current_user.transactions.where(:state => "complete")
	end

  def order
    @transaction = current_user.transactions.where(:state => "complete").find(params[:order_id])
  end

  def create
    opt = params[:product_comment]
    content, id = opt.delete(:content), opt.delete(:id)
    product_item_id = opt.delete(:product_item_id)
    @item = ProductItem.find_by(:id => product_item_id, :user_id => current_user.id)

    respond_to do |format|
      @product_comment = if id.blank?
        ProductComment.create(opt.merge(product_item: @item))
      else
        ProductComment.find(id)
      end
      if @product_comment.valid?
        @comment = Comment.new(
          :content => content, :user_id => current_user.id)
        @comment.targeable = @product_comment
        @comment.save
        format.json{ render :json => @comment  }
      else
        format.json{ render :json => draw_errors_message(@product_comment), :status => 403 }
      end
    end
  end
end
