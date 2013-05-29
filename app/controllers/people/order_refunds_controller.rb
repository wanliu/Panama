class People::OrderRefundsController < People::BaseController

  def index
    @refunds = OrderRefund.where(:buyer_id => @people.id)
  end
end