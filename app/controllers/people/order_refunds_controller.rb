#encoding: utf-8

class People::OrderRefundsController < People::BaseController
  before_filter :login_and_service_required

  def index
    @refunds = current_user_refunds.uncomplete.order("created_at desc").page(params[:page])
  end

  def show
    @refund = current_user_refunds.find(params[:id])
  end

  def page
    @refund = current_user_refunds.find(params[:id])
  end

  def card
    @refund = current_user_refunds.find(params[:id])
  end

  def mini_item
    @refund = current_user_refunds.find(params[:id])
    respond_to do |format|
      format.html{ render :layout => false }
    end
  end

  def event
    @refund = current_user_refunds.find_by(:id => params[:id])
    if @refund.buyer_fire_event(params[:event])
      render :partial => "card", :locals => {
        :refund => @refund
      }
    else
      render :json => draw_errors_message(@refund), :status => 403
    end
  end

  def update_delivery_price
    @refund = current_user_refunds.find(params[:id])
    respond_to do |format|
      @refund.update_attributes(
        :delivery_price => params[:delivery_price])
      if @refund.valid?
        format.json{ render :json => {
          :delivery_price => @refund.delivery_price,
          :stotal => @refund.stotal
        }}
      else
        format.json{ render :json => draw_errors_message(@refund), :status => 403 }
      end
    end
  end

  def update_delivery
    @refund = current_user_refunds.find_by(:id => params[:id])
    @refund.delivery_code = params[:delivery_code]
    @refund.transport_type = params[:transport_type]
    respond_to do |format|
      if @refund.save
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@refund), :status => 403}
      end
    end
  end

  def destroy
    @refund = current_user_refunds.find_by(:id => params[:id])
    @refund.destroy
    respond_to do |format|
      format.json{ head :no_content }
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