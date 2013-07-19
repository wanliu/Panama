class CompletingShopController < Wicked::WizardController
  layout "wizard"

  steps :pick_industry, :authenticate_license, :pick_product, :waiting_audit

  def show
  	@shop_auth = ShopAuth.new
    service_id = Service.where(service_type: "seller").first.id
    @user_checking = current_user.user_checking || current_user.create_user_checking(service_id: service_id)

    render_wizard
  end

  def update
    @user_checking = current_user.user_checking
    case step
    when :pick_industry
      save_industry_type
    when :authenticate_license
      save_license
    when :pick_product
      save_products
    end
  end

  private
  def save_industry_type
    @user_checking.update_attributes(params[:user_checking])
    render_wizard(@user_checking)
  end

  def save_license
    @shop_auth = ShopAuth.new(params[:shop_auth])
    if @shop_auth.valid?
      # next_step
      # @user_checking.update_attributes(@shop_auth.update_options)
      redirect_to wizard_path(:pick_product)
    else
      render_wizard
    end
  end

  def save_products
  end
end
