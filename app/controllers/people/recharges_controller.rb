#用户充值
class People::RechargesController < People::BaseController
  before_filter :login_required

  #网上银行充值
  def ibank
    @money_bill = current_user.recharge(
      :owner => Bank.find(params[:trade_income][:bank_id]),
      :money => params[:trade_income][:money])

    respond_to do |format|
      if @money_bill.valid?
        format.html{
          redirect_to person_transactions_path(current_user.login)
        }
      else
        format.json{ render :json => draw_errors_message(@income) }
      end
    end
  end

  #电汇
  def remittance
  end

end