class Admins::Shops::TransactionsController < Admins::Shops::SectionController

  def pending
    @transactions = OrderTransaction.where(:seller_id => current_shop.id)
  end

  def show
  	@transaction = OrderTransaction.find_by(:seller_id => current_shop.id, :id => params[:id])
  	respond_to do | format |
  		format.html
  	end
  end


  def event
    @transaction = OrderTransaction.find(params[:id])
    # authorize! :event, @transaction
    if @transaction.fire_events!(params[:event])
      render partial: 'transaction',
                   object:  @transaction,
                   locals: {
                     state:  @transaction.state,
                     people: @people
                   }
      # render :partial => 'transaction', :transaction => @transaction, :layout => false
      # redirect_to person_transaction_path(@people.login, @transaction)
    end
  end
end
