class Admins::Shops::OrderRefundsController < Admins::Shops::SectionController

  def index
    @refunds = current_shop_refunds
  end

  def show
    @refund = current_shop_refunds.find_by(:id => params[:id])
  end

  def event
    @refund = current_shop_refunds.find_by(:id => params[:id])
    if @refund.seller_fire_events!(params[:event])
      render :partial => "context", :locals => {refund: @refund}
    end
  end

  def refuse_reason
    @refund = current_shop_refunds.find_by(:id => params[:id])
    @refund.refuse_reason = params[:refuse_reason]
    respond_to do |format|
      if @refund.save
        format.json{ head :no_context }
      else
        format.json{ render :json =>draw_errors_message(@refund), :status => 403 }
      end
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