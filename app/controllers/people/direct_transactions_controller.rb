#encoding: utf-8
class People::DirectTransactionsController < People::BaseController
  include TransactionHelper
  before_filter :login_and_service_required, :person_self_required

  def index
    @direct_transactions = current_user.direct_transactions.uncomplete.order("created_at desc").page(params[:page])
  end

  def generate_token
    respond_to do |format|
      format.json{ render :json => { token: get_token(current_direct_transaction) } }
    end
  end

  def dialog
    @direct_transaction = current_direct_transaction
    render :partial => "direct_transactions/dialog",
    :layout => "message", :locals => {
      :direct_transaction => @direct_transaction,
      :dtm_url => person_direct_transaction_path(@people, @direct_transaction)
    }
  end

  def page
    @direct_transaction = current_direct_transaction
    render :layout => false
  end

  def completed
    @direct_transaction = current_direct_transaction
    @direct_transaction.state = :complete
    @direct_transaction.address = generate_address
    respond_to do |format|
      if @direct_transaction.save
        format.json{ render :json => @direct_transaction }
      else
        format.json{ render :json => draw_errors_message(@direct_transaction), :status => 403 }
      end
    end
  end

  def destroy
    @direct_transaction = current_direct_transaction

    respond_to do |format|
      if @direct_transaction.state == :uncomplete
        @direct_transaction.destroy
        format.json{ head :no_content }
      else
        format.json{ render :json => ["已经交易成功不能删除！"], :status => 403 }
      end
    end
  end

  def show
    @direct_transaction = current_direct_transaction
  end

  def mini_item
    @direct_transaction = current_direct_transaction
    respond_to do |format|
      if @direct_transaction.present?
        format.html{ render :layout => false }
      else
        format.json{ render :json => ["直接交易不存在！"], :status => 403 }
      end
    end
  end

  def page
    @direct_transaction = current_direct_transaction
    respond_to do |format|
      format.html{ render :layout => false }
    end
  end

  def operator
    @operator = current_direct_transaction.operator
    respond_to do |format|
      format.html{ 
        render :partial => "direct_transactions/operator", :locals => {operator: @operator} }
    end
  end


  def generate_address
    args = params[:data][:direct_transaction]
    address_id = args.delete(:address_id)
    if address_id.present?
      DeliveryAddress.find(address_id)
    else
      current_user.delivery_addresses.create(gener_address_arg(params[:data][:address]))
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

  private
  def current_direct_transaction
    @people.direct_transactions.find_by(id: params[:id])
  end
end