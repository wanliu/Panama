#encoding: utf-8
class People::TransactionsController < People::BaseController
  before_filter :login_and_service_required, :person_self_required, :except => [:kuaiqian_receive]
  helper_method :base_template_path

  def index
    authorize! :index, OrderTransaction
    @transactions = current_order.uncomplete.order("created_at desc").page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @transactions }
    end
  end

  def get_token
    @transaction.temporary_channel.try(:token)
  end

  def generate_token
    @transaction = current_order.find(params[:id])
    if get_token.blank?
      @transaction.send('create_the_temporary_channel')
      try_times = 0
      Thread.new do
        while try_times < 50 do
          try_times += 1
          break unless get_token.blank?
          sleep 0.2
        end
      end
    end
    
    respond_to do |format|
      format.json{ render :json => { token: get_token } }
    end
  end

  def show
    @transaction = current_order.find(params[:id])
    @pay_msg = params[:pay_msg]
    authorize! :show, @transaction
    respond_to do |format|
      format.html
      format.json{ render json: @transaction }
      format.csv{
        send_data(to_csv(OrderTransaction.export_column, @transaction.convert_json),
          :filename => "order#{DateTime.now.strftime('%Y%m%d%H%M%S')}.csv")
      }
    end
  end

  def card
    @transaction = current_order.find(params[:id])
    respond_to do |format|
      format.html{ render :layout => false }
    end
  end

  def mini_item
    @transaction = current_order.find_by(:id => params[:id])
    respond_to do |format|
      if @transaction.present?
        format.html{ render :layout => false }
      else
        format.json{ render :json => ["该订单不存在！"], :status => 403 }
      end
    end
  end

  def print
    @transaction = current_order.find(params[:id])
    render :layout => "print"
  end

  def page
    @transaction = current_order.find(params[:id])
    authorize! :show, @transaction
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def event
    @transaction = current_order.find(params[:id])
    event_name = params[:event]
    authorize! :event, @transaction

    if @transaction.buyer_fire_event(event_name)
      render_base_template "card", :transaction => @transaction
    else
      render :json => draw_errors_message(@transaction), :status => 403
    end
  end

  def batch_create
    authorize! :batch_create, OrderTransaction
    item_ids = params[:items].map{ |k, v| 
      v[:id].to_i if v[:checked] == 'on' }.compact    
    respond_to do |format|      
      if my_cart.create_transaction(@people, item_ids)
        url = cart_transaction_path
        format.js{
          render :js => "window.location.href='#{url}'" }
        format.html{
          redirect_to url }
      else
        format.json{ 
          render :json => draw_errors_message(my_cart), :status => 403 }
        format.html{
          redirect_to person_cart_index_path(@people.login),
                    notice: 'We are sorry, but the transaction was not successfully created.'}
      end
    end
  end

  def kuaiqian_payment
    @transaction = current_order.find(params[:id])
    options = {
      :bg_url => paid_send_url,
      :payer_name => current_user.login,
      :order_id => @transaction.number,
      :order_amount => (@transaction.stotal * 100).to_i,
      :product_name => @transaction.items[0].title,
      :product_num => @transaction.items_count,
      :order_time => Time.now.strftime("%Y%m%d%H%M%S")
    }
    options.merge!(:pay_type => "10",
      :bank_id => params[:bank]) if params[:bank].present?
    pay_ment = KuaiQian::PayMent.request(options)
    respond_to do |format|
      format.js{ 
        render :js => "window.location.href='#{pay_ment.url}'" }
      format.html{ redirect_to pay_ment.url }
    end
  end

  def kuaiqian_receive
    _response = KuaiQian::PayMent.response(params)
    @transaction = current_order.find(params[:id])
    state = if _response.successfully?
      @transaction.kuaiqian_paid
      "success"
    else
      "error"
    end
    url = "#{paid_receive_url(@transaction)}?pay_msg=#{state}"    
    render :xml => {
      :result => "1", 
      :redirecturl => url }
  end

  def receive
    @transaction = current_order.find(params[:id])
    @pay_msg = params[:pay_msg] == "success" ? "成功" : "失败"
  end

  def test_payment
    @transaction = current_order.find(params[:id])
    if payment_mode?     
      respond_to do |format|
        if @transaction.kuaiqian_paid 
          url = "#{receive_person_transaction_path(@people, @transaction)}?pay_msg=success"
          format.js{ 
            render :js => "window.location.href='#{url}'" }
          format.html{ redirect_to url }
        else
          format.json{ render :json => draw_errors_message(@transaction), :status => 403 }
        end      
      end
    end
  end

  def base_info
    @transaction = current_order.find(params[:id])
    respond_to do |format|
      @transaction.address = generate_address
      if @transaction.address.valid? 
        if @transaction.update_attributes(params[:order_transaction])
          format.json { render :json => {:event => @transaction.pay_type_name} }
        else
          format.json { render :json => draw_errors_message(@transaction), :status => 403 }
        end
      else
        format.html{ render error_back_address_html }
      end
    end
  end

  def transfer
    @transaction = current_order.find(params[:id])
    @transfer = @transaction.create_transfer(params[:transfer])
    respond_to do |format|
      if @transfer.valid?
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@transfer), :status => 403 }
      end
    end
  end

  def completed
    @orders = OrderTransaction.buyer(@people).completed.order("created_at desc").page(params[:page])
    @directs = DirectTransaction.completed.where(:buyer_id => @people.id).order("created_at desc").page(params[:page])
    @refunds = OrderRefund.completed.where(:buyer_id => @people.id).order("created_at desc").page(params[:page])
  end

  def refund
    order, options = current_order.find(params[:id]), params[:order_refund]
    respond_to do |format|
      refund = order.refunds.create(options)
      if refund.valid?
        refund.create_items(order.items.pluck("id"))
        if refund.items.count <= 0
          refund.destroy
          format.json{ render :json => ["申请退货失败：您选择退货的商品已经在退货之中，或者不能退货"],
                              :status => 403 }
        else
          format.json{ render :json => refund }
        end
      else
        format.json{ render :json => draw_errors_message(refund), :status => 403 }
      end
    end
  end

  def delay_sign
    order = current_order.find(params[:id])    
    respond_to do |format| 
      if order.waiting_sign_state?  
        @detail = order.current_state_detail
        @detail.delay_sign_expired
        if @detail.valid?
          format.json{ head :no_content }
        else
          format.json{ render :json => draw_errors_message(@detail), :status => 403 }
        end
      else
        format.json{ render :json => ["当前订单状态不能延时！"], :status => 403 }
      end
    end
  end

  def direct
    @shop_product = ShopProduct.find(params[:shop_product_id])
  end

  def operator
    @operator = current_order.find(params[:id]).current_operator
    respond_to do |format|
      format.html{ render :partial => "transactions/operator", :locals => {operator: @operator} }
    end
  end

  def destroy
    @transaction = current_order.find(params[:id])
    authorize! :destroy, @transaction

    respond_to do |format|
      if @transaction.close_state?
        @transaction.destroy
        format.html { redirect_to person_transactions_path(@people.login) }
        format.json { head :no_content }
      else
        format.json{ render :state => 403 }
      end
    end
  end
  
  private
  def current_order
    OrderTransaction.where(:buyer_id => @people.id)
  end

  def render(*args)
    options = args.extract_options!
    if request.xhr?
      options[:layout] = false
    end

    super *args, options
  end

  def error_back_address_html
    { partial: "people/transactions/funcat/address",
      layout: false,
      status: '400 Validation Error',
      locals: { :transaction => @transaction,
                :people => @people } }
  end

  def generate_address
    args = params[:order_transaction]
    address_id = args.delete(:address_id)
    if address_id.present?
      DeliveryAddress.find(address_id)
    else
      current_user.delivery_addresses.create(gener_address_arg(params[:address]))
    end
  end

  def gener_address_arg(a)
    {
      :province_id => a[:province_id],
      :city_id => a[:city_id],
      :area_id => a[:area_id],
      :zip_code => a[:zip_code],
      :road => a[:road],
      :contact_name => a[:contact_name],
      :contact_phone => a[:contact_phone]
    }
  end

  def paid_receive_url(order)
    "#{Settings.site_url}#{receive_person_transaction_path(@people, order)}"
  end

  def paid_send_url
    "#{Settings.site_url}#{kuaiqian_receive_person_transaction_path(current_user, @transaction)}"
  end

  def base_template_path
    "people/transactions/base"
  end

  def cart_transaction_path
    if my_cart.items.map{|item| item.buy_state.name }.include?(:guarantee)
      person_transactions_path(@people.login)
    else
      person_direct_transactions_path(@people.login)
    end
  end
end
