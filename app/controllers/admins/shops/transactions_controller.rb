class Admins::Shops::TransactionsController < Admins::Shops::SectionController

  def pending
    @transactions = Transaction.where(:seller => current_shop).page 
    @orders = []    
  end
end
