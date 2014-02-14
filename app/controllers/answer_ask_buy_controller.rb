class AnswerAskBuyController < ApplicationController
  before_filter :login_and_service_required
  layout "application"

  def index
  end

  def create
    @ask_buy = AskBuy.find(params[:answer_ask_buy][:ask_buy_id])
    respond_to do |format|
      if current_user.id == @ask_buy.user_id || !current_user.is_seller? 
        format.json{ render :json => ['不能参与自己的求购或者不是供应商！'], :status => 403 }
      elsif !@ask_buy.open || !current_user.answered_ask_buy(@ask_buy.id).nil?
        format.json{ render :json => ['您已经参与过此求购,或此求购已经被关闭'], :status => 403 }
      else
        all_params = params[:answer_ask_buy].merge!(:user_id => current_user.id)
        @answer_ask_buy = AnswerAskBuy.create(all_params) unless @ask_buy.nil?
        if @answer_ask_buy.valid?
          format.html
          format.json{ render :no_content}
        else
          format.json{ render json: draw_errors_message(@answer_ask_buy), status: 403 }
        end
      end
    end
  end

  def create_order
    @answer_ask_buy = AnswerAskBuy.find(params[:id])
    respond_to do |format|
      if @answer_ask_buy.ask_buy.open
        @order = current_user.transactions.build(seller_id: @answer_ask_buy.seller_shop.id)
        @item = @order.items.build({
          :product_id  => @answer_ask_buy.shop_product.product_id,
          :amount => @answer_ask_buy.amount,
          :title  => @answer_ask_buy.shop_product_name,
          :price  => @answer_ask_buy.price,
          :user_id => @answer_ask_buy.buyer.id,
          :shop_id => @answer_ask_buy.seller_shop.id
        })
        @item.buy_state = :guarantee
        if @order.save        
          @answer_ask_buy.convert_to_order(@order.id)
          format.json{ render :json => @order }
        else
          format.json{ render :json => draw_errors_message(@order), :status => 403 }
        end
      else
        format.json{ render :json => ['此求购已经被关闭,不能进行交易'], :status => 403 }
      end
    end
  end
end
