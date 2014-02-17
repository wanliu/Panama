class OrderTransactionDecorator < Draper::Decorator
  decorates_association :items
  delegate_all
  delegate :current_page, :total_pages, :limit_value, to: :source

  def total
    h.number_to_currency(source.total)
  end

end