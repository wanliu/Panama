class CompletingPeopleController < Wicked::WizardController
  layout "sigin"

  steps :pick_industry, :authenticate_license

  def show
  	@user_auth = UserAuth.new
    render_wizard
  end

  def update
  	@user_auth = UserAuth.new(params[:user_auth])
  	if @user_auth.valid?

    else
      format.html{ render error_back_complete_people_html }
    end
  end

  private

end
