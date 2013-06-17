class CompletingPeopleController < Wicked::WizardController
  layout "sigin"

  steps :authenticate_license


  def show
    render_wizard
  end
end
