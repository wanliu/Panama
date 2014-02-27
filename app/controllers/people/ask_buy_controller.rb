class People::AskBuyController < People::BaseController
	before_filter :login_required, :person_self_required

  def index
    @ask_buy = AskBuy.where(:user_id => current_user.id)
  end

end