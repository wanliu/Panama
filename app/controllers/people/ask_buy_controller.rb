class People::AskBuyController < People::BaseController

  def index
    @ask_buy = AskBuy.where(:user_id => current_user.id)
  end

end