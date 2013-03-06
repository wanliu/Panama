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
end
