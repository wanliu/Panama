#用户充值
class People::RechargesController < People::BaseController
  before_filter :login_and_service_required

  #网上银行充值
  def ibank
    t = params[:trade_income]
    @money_bill = current_user.recharge(t[:money], Bank.find(t[:bank_id]))

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