#用户充值
class People::RechargesController < People::BaseController
  before_filter :login_required

  def create
    @income = TradeIncome.new(params[:trade_income])
    @income.buyer_id = current_user.id
    respond_to do |format|
      if @income.save
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@income) }
      end
    end
  end
end