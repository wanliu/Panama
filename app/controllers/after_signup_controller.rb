class AfterSignupController < Wicked::WizardController
  layout "wizard"

  steps :select_type

  def show
    @user = current_user
    render_wizard
  end
end
