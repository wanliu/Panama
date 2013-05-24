#用户充值
class People::RechargesController < People::BaseController
  before_filter :login_required

  def create
    @income = TradeIncome.new(params[:trade_income])
    @income.buyer_id = current_user.id
    respond_to do |format|
      if @income.save
        format.html{
          redirect_to person_transactions_path(current_user.login)
        }
      else
        format.json{ render :json => draw_errors_message(@income) }
      end
    end
  end
end