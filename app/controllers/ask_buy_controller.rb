#encoding: utf-8
class AskBuyController < ApplicationController
  before_filter :login_and_service_required

  def new
    @ask_buy = AskBuy.new
    respond_to do |format|
      format.html{ render :layout => false }
      format.dialog{ render "new.dialog", :layout => false }
    end
  end

  def create
    @product = Product.find_by(:name => params[:ask_buy][:title])
    params[:ask_buy][:product_id] = @product.try(:id)
    attachment_ids = params[:ask_buy].delete(:attachment_ids) || []
    @ask_buy = AskBuy.new(params[:ask_buy])
    @ask_buy.user_id = current_user.id
    @ask_buy.attachments = attachment_ids.map do | k,v |
      Attachment.find_by(:id => v)
    end.compact

    respond_to do |format|
      if @ask_buy.save
        format.json{ render :json => @ask_buy }
      else
        format.json{ render "new.dialog" }
      end
    end
  end

  def show
    @ask_buy = AskBuy.find(params[:id])
    respond_to do |format|
      format.json do
        ask_buy = @ask_buy.as_json
        ask_buy["comments"] = @ask_buy.comments{|c| c.as_json}
        render :json => ask_buy
      end
      format.dialog{ render :layout => false }
    end
  end

  def comment
    @ask_buy = AskBuy.find(params[:id])
    @comment = @ask_buy.comments.build(params[:comment])
    @comment.user_id = current_user.id
    respond_to do |format|
      if @comment.save
        format.json{ render :json => @comment }
      else
        format.json{ render :json => draw_errors_message(@comment), :status => 403 }
      end
    end
  end

  def join
    @ask_buy = AskBuy.find(params[:id])
    respond_to do |format|
      if current_user.id == @ask_buy.user_id || !current_user.is_seller? || @ask_buy.paticipate.present?
        format.json{ render :json => ['不能参与自己的求购或者不是供应商！'], :status => 403 }
      else
        @paticipate = AskBuyPaticipate.create(
          :ask_buy => @ask_buy,
          :user => current_user,
          :shop => current_user.shop)
        if @paticipate.valid?
          format.json{ head :no_content }
        else
          format.json{ render :json => draw_errors_message(@paticipate), :status => 403 }
        end
      end
    end
  end

end