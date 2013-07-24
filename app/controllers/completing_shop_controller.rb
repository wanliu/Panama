class CompletingShopController < Wicked::WizardController
  layout "wizard"

  steps :pick_industry, :authenticate_license, :pick_product, :waiting_audit

  def show
    service_id = Service.where(service_type: "seller").first.id
    @user_checking = current_user.user_checking || current_user.create_user_checking(service_id: service_id)
    @shop_auth = ShopAuth.new(@user_checking.attributes)

    if @user_checking.checked
      redirect_to "/"
    else
      case step
      when :pick_product
        @products = ShopProduct
          .joins(:product)
          .select(["shop_products.*", "products.name"])
          .where("shop_products.shop_id = ? ", @current_user.shop.id)
      end
      render_wizard
    end
  end

  def update
    @user_checking = current_user.user_checking
    case step
    when :pick_industry
      save_industry_type
    when :authenticate_license
      save_license
    when :pick_product
      set_products_added
    end
  end

  private
  def save_industry_type
    @user_checking.update_attributes(params[:user_checking])
    render_wizard(@user_checking)
  end

  def save_license
    @shop_auth = ShopAuth.new(params[:shop_auth].merge(user_id: @user_checking.user.id))
    if @shop_auth.valid?
      @user_checking.update_attributes(@shop_auth.update_options.merge(rejected: false))
      if @user_checking.user.shop.blank?
        @user_checking.user.create_shop(name: @shop_auth.shop_name)
      end
      render_wizard(@user_checking)
    else
      render_wizard
    end
  end

  def set_products_added
    @user_checking.update_attributes(products_added: true)
    render_wizard(@user_checking)
  end
end
