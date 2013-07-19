class CompletingShopController < Wicked::WizardController
  layout "wizard"

  steps :pick_industry, :authenticate_license, :pick_product, :waiting_audit

  def show
    service_id = Service.where(service_type: "seller").first.id
    @user_checking = current_user.user_checking || current_user.create_user_checking(service_id: service_id)

    @shop_auth = ShopAuth.new(@user_checking.attributes)

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
      @user_checking.update_attributes(@shop_auth.update_options)
      # redirect_to wizard_path(:pick_product)
      render_wizard(@user_checking)
    else
      render_wizard
    end
  end

  def save_products
  end
end
