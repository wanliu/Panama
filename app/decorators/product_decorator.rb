class ProductDecorator < Draper::Decorator
  delegate_all

  def price
    h.number_to_currency(source.price).delete("CN")
  end

  # def photos
  #   source.photos
  # end
end