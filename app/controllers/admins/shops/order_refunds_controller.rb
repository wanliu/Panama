class Admins::Shops::OrderRefundsController < Admins::Shops::SectionController

  def index
    @refunds = current_shop_refunds.uncomplete.order("created_at desc").page(params[:page])
  end

  def show
    @refund = current_shop_refunds.find_by(:id => params[:id])
  end

  def page
    @refund = current_shop_refunds.find_by(:id => params[:id])
  end

  def card
    @refund = current_shop_refunds.find_by(:id => params[:id])
  end

  def event
    @refund = current_shop_refunds.find_by(:id => params[:id])
    if @refund.seller_fire_events!(params[:event])
      render :partial => "card", :locals => {refund: @refund}
    else
      render :json => {message: "#{params[:event]}不属于你的!"}, :status => 403
    end
  end

  def refuse_reason
    @refund = current_shop_refunds.find_by(:id => params[:id])
    @refund.refuse_reason = params[:refuse_reason]
    respond_to do |format|
      if @refund.save
        format.json{ head :no_content }
      else
        format.json{ render :json =>draw_errors_message(@refund), :status => 403 }
      end
    end
  end

  def mini_item
    @refund = current_shop_refunds.find_by(:id => params[:id])
    respond_to do |format|
      format.html{
        render :layout => false }      
    end
  end

  private
  def current_shop_refunds
    OrderRefund.where(:seller_id => current_shop.id)
  end

  def render(*args)
    options = args.extract_options!
    if request.xhr?
      options[:layout] = false
    end

    super *args, options
  end
end