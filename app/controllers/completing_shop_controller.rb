class CompletingShopController < Wicked::WizardController
  layout "sigin"

  steps :pick_industry, :authenticate_license, :pick_product, :waiting_audit

  def show
  	@shop_auth = ShopAuth.new
    render_wizard
  end

  def update
    case step
    when :pick_industry
      
  	when :authenticate_license
      save_license
    when :waiting_audit

    end
  end

  private
  def save_license
    @shop_auth = ShopAuth.new(params[:shop_auth])
    if @shop_auth.valid?
      next_step
    end
    render_wizard
  end
end
