class People::OrderRefundsController < People::BaseController
  before_filter :login_required

  def index
    @refunds = current_user_refunds.order("created_at desc")
  end

  def show
    @refund = current_user_refunds.find(params[:id])
  end

  def page
    @refund = current_user_refunds.find(params[:id])
  end

  def event
    @refund = current_user_refunds.find_by(:id => params[:id])
    if @refund.buyer_fire_events!(params[:event])
      @refund.notice_change_seller(params[:event])
      render :partial => "context", :locals => {
        :refund => @refund
      }
    end
  end

  def update_delivery_price
    @refund = current_user_refunds.find(params[:id])
    respond_to do |format|
      if @refund.update_attributes(:delivery_price => params[:delivery_price])
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@refund), :status => 403 }
      end
    end
  end

  def delivery_code
    @refund = current_user_refunds.find_by(:id => params[:id])
    @refund.delivery_code = params[:delivery_code]
    respond_to do |format|
      if @refund.save
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@refund), :status => 403}
      end
    end
  end

  private
  def current_user_refunds
    OrderRefund.where(:buyer_id => @people.id)
  end

  def render(*args)
    options = args.extract_options!
    if request.xhr?
      options[:layout] = false
    end

    super *args, options
  end
end