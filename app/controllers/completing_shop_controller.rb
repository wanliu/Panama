class CompletingShopController < Wicked::WizardController
  layout "sigin"

  steps :pick_industry, :authenticate_license, :pick_product

  def show
    render_wizard
  end
end
