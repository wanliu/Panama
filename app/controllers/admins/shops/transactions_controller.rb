#encoding: utf-8
class Admins::Shops::TransactionsController < Admins::Shops::SectionController
  helper_method :base_template_path

  def pending
    @untransactions = current_shop_order.where(:operator_state => false)
    @transactions = current_shop_order.uncomplete.joins(:operator)
    .where("operator_state=true and transaction_operators.operator_id=?", current_user.id)
    .order("dispose_date desc").page(params[:page])
  end

  def generate_token
    @transaction = current_shop_order.find(params[:id])
    @transaction.send('create_the_temporary_channel')
    
    respond_to do |format|
      format.json{ render :json => { token: @transaction.temporary_channel.try(:token) } }
    end
  end

  def complete
    @transactions = current_shop_order.completed.order("created_at desc").page(params[:page])
    @directs = current_shop.direct_transactions.completed.order("created_at desc").page(params[:page])
    @refunds = current_shop.order_refunds.completed.order("created_at desc").page(params[:page])
  end

  def page
    @transaction = current_shop_order.find_by(:id => params[:id])
    respond_to do | format |
      format.html
    end
  end

  def card
    @transaction = current_shop_order.find_by(:id => params[:id])    
  end

  def print
    @transaction = current_shop_order.find_by(:id => params[:id])
    render :layout => "print"
  end

  def show
    @transaction = current_shop_order.find_by(:id => params[:id])
    respond_to do | format |
      format.html
      format.json{ render :json => @transaction.as_json(:methods => :seller_state_title) }
      format.csv do
        send_data(to_csv(OrderTransaction.export_column, @transaction.convert_json),
          :filename => "order#{DateTime.now.strftime('%Y%m%d%H%M%S')}.csv")
      end
    end
  end

  def mini_item
    @transaction = current_shop_order.find_by(:id => params[:id])
    respond_to do | format |
      format.html{ render :layout => false }
    end
  end

  def event
    @transaction = current_shop_order.find_by(:id => params[:id])
    if @transaction.seller_fire_event!(params[:event])
      render_base_template 'card', :transaction => @transaction
    else
      redirect_to shop_admins_pending_path(current_shop.name)
    end
  end

  def update_delivery
    @transaction = current_shop_order.find(params[:id])
    respond_to do |format|
      @transaction.delivery_code = params[:delivery_code]
      if @transaction.save
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@transaction), :status => 403 }
      end
    end
  end

  def update_delivery_price
    @transaction = current_shop_order.find(params[:id])
    respond_to do |format|
      @transaction.delivery_price = params[:delivery_price] || 0
      if @transaction.save
        format.json{ head :no_content }
      else
        format.json{ render draw_errors_message(@transaction), :status => 403  }
      end
    end
  end

  #处理订单
  def dispose
    @transaction = current_shop_order.find_by(:id => params[:id])
    respond_to do |format|
      @operator = @transaction.operator_create(current_user.id)
      if @operator.valid?   
        format.html
        format.json{ 
          render :json => @transaction }
      else
        format.json{
          render :json => draw_errors_message(@operator), :status => 403 }
      end
    end
  end

  private
  def render(*args)
    options = args.extract_options!
    if request.xhr?
      options[:layout] = false
    end

    super *args, options
  end

  def current_shop_order
    OrderTransaction.seller(current_shop)
  end

  def base_template_path
    "admins/shops/transactions/base"
  end
end
