class AfterSignupController < Wicked::WizardController
  layout "sigin"

  steps :select_type

  def show
    @user = current_user
    render_wizard
  end
end
