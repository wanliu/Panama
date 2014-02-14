class People::WithdrawMoneyController < People::BaseController
  
  def index
    authorize! :manage, User
  end

  def create
    authorize! :manage, User
    @withdraw = current_user.withdraw_money.build(params[:withdraw])
    respond_to do |format|
      if @withdraw.save
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@withdraw), :status => 403 }
      end
    end
  end

  def title
    "提现"
  end
end