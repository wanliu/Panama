class OrderTransactionDecorator < Draper::Decorator

  def total 
    h.number_to_currency(source.total).delete("CN")
  end
 
end