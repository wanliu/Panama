# encoding: utf-8
#用户充值
class People::RechargesController < People::BaseController
  before_filter :login_and_service_required

  #网上银行充值
  def index
    authorize! :manage, User    
  end

  def payment
    @recharge = Recharge.kuaiqian(
      :money => params[:money],
      :user => current_user)
    respond_to do |format|
      if @recharge.valid?
        options = base_options
        options[:bg_url] = paid_redirect_url
        options[:order_amount] = (@recharge.money * 100).to_i
        options.merge!(:pay_type => "10",
          :bank_id => params[:bank]) if params[:bank].present?
        _request = KuaiQian::PayMent.request(options)
        format.js{ render :js => "window.location.href='#{_request.url}'" }
        format.html{ redirect_to _request.url }
      else
        format.json{ render :json => draw_errors_message(@recharge), :status => 403 }
      end   
    end
  end

  def test_payment
    respond_to do |format|
      if payment_mode?
        @recharge = Recharge.kuaiqian(
        :money => params[:money],
        :user => current_user)
        if @recharge.valid?
          @recharge.successfully
          url = person_recharge_path(current_user, @recharge)
          format.js{ render :js => "window.location.href='#{url}'" }
          format.html{ redirect_to url }
        else
          format.json{ render :json => draw_errors_message(@recharge), :status => 403 }
        end
      else
        format.json{ render :json => ["没有开启测试模式，不能使用！"], :status => 403 }
      end
    end
  end

  def receive
    @recharge = Recharge.find(params[:id])
    _response = KuaiQian::PayMent.response(params)
    @recharge.successfully if _response.successfully?
    render :xml => {:result => "1", :redirecturl => receive_redirect_url }
  end

  def show
    @recharge = Recharge.find_by(id: params[:id], user_id: current_user.id)
  end

  def title
    "用户充值"
  end

  private 
  def paid_redirect_url
    "#{Settings.site_url}#{receive_person_recharge_path(current_user, @recharge)}"
  end

  def receive_redirect_url
    "#{Settings.site_url}#{person_recharge_path(current_user, @recharge)}"
  end

  def base_options
    {      
      :payer_name => current_user.login,
      :order_id => Time.now.strftime("%Y%m%d%H%M%S%4N"),
      :product_name => "用户充值",
      :product_num => 1,
      :order_time => Time.now.strftime("%Y%m%d%H%M%S")
    }
  end
end