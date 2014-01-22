#encoding: utf-8
class People::DirectTransactionsController < People::BaseController

  def index
    @direct_transactions = current_user.direct_transactions.uncomplete.order("created_at desc").page(params[:page])
  end

  def generate_token
    @direct_transaction = current_direct_transaction
    @direct_transaction.send('create_the_temporary_channel')
    
    respond_to do |format|
      format.json{ render :json => { token: @direct_transaction.temporary_channel.try(:token) } }
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
      format.html{ render :layout => false }
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

  private
  def current_direct_transaction
    @people.direct_transactions.find(params[:id])
  end
end