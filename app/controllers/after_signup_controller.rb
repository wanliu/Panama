class AfterSignupController < Wicked::WizardController
  layout "wizard"

  steps :select_type

  def show
    if current_user.user_checking.blank?
    	render_wizard
    else
    	@user_checking = current_user.user_checking
    	@user_auth = UserAuth.new

    	wizard_controller = if @user_checking.service == "buyer"
    		[CompletingPeopleController, "people"]
    	else
    		[CompletingShopController, "shop"]
    	end
    	wizard_url = "/completing_" << wizard_controller.last
    	redirect_to "#{ wizard_url }/#{ @user_checking.current_step }"
    end
  end
end
