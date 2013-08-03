class AskBuyController < ApplicationController
  before_filter :login_required

  def new
    @ask_buy = AskBuy.new
    respond_to do |format|
      format.html{ render :layout => false }
      format.dialog{ render "new.dialog", :layout => false }
    end
  end

  def create
    @product = Product.find_by(:name => params[:ask_buy][:title])
    params[:ask_buy][:product_id] = @product.id if @product.present?
    @ask_buy = AskBuy.new(params[:ask_buy])
    @ask_buy.user_id = current_user.id
    @ask_buy.attachments = params[:ask_buy][:attachment_ids].map do | k,v |
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
      format.json{ render :json => @ask_buy.as_json(:include => :comments) }
    end
  end
end