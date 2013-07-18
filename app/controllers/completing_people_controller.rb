class CompletingPeopleController < Wicked::WizardController
  layout "sigin"

  steps :authenticate_license


  def show
  	@user_auth = UserAuth.new
    render_wizard
  end

  def update
  	# @user_auth = UserAuth.new(params[:user_auth])
  	# if @user_auth.valid?
  end
end
