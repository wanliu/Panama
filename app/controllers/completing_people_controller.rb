class CompletingPeopleController < Wicked::WizardController
  layout "sigin"

  steps :pick_industry, :authenticate_license


  def show
    render_wizard
  end
end
