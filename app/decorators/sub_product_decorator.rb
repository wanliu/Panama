class SubProductDecorator < Draper::Decorator

  def price
    h.number_to_currency(source.price).delete("CN")
  end
 
end