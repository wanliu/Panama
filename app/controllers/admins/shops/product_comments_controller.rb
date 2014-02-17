class Admins::Shops::ProductCommentsController < Admins::Shops::SectionController

  def index
    @product_comments = ProductComment.shop(current_shop)
  end

  def reply
    @product_comment = ProductComment.shop(current_shop).find(params[:id])
    @reply = @product_comment.comment.replies.create(
      :content => params[:content],
      :user_id => current_user.id)
    respond_to do |format|
      if @reply.valid?
        format.json{ render :json => @reply }
      else
        format.json{ render :json => draw_errors_message(@reply) }
      end
    end
  end
end