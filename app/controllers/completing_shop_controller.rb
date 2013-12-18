class CompletingShopController < Wicked::WizardController
  layout "wizard"
  before_filter :login_required_without_service_seller

  steps :pick_industry, :authenticate_license, :pick_product

  def show
    service_id = Service.where(service_type: "seller").first.id
    # @user_checking = current_user.user_checking.where(service_id: service_id).first_or_create

    @user_checking = UserChecking.where(service_id: service_id, user_id: current_user.id).first_or_create

    # @user_checking = current_user.user_checking
    # unless @user_checking.update_attributes(service_id: service_id)
    #   @user_checking = current_user.create_user_checking(service_id: service_id)
    # end

    @shop_auth = ShopAuth.new(@user_checking.attributes)
    if @user_checking.checked && current_user.try(:shop).try(:actived)
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

  def edit_address
    @address = current_user.user_checking.address || Address.new
    render layout: false, partial: "completing_shop/edit_address"
  end

  def update_address
    @address = current_user.user_checking.address
    if @address.blank?
      @address = Address.create(params[:address])
      current_user.user_checking.update_attribute(:address_id, @address.id)
    else
      @address.update_attributes(params[:address])
    end

    if @address.valid?
      render json: { id: @address.id, address: @address.address_only }
    else
      render layout: false, status: 400, partial: "completing_shop/edit_address"
    end
  end

  private
  def save_industry_type
    @user_checking.update_attributes(params[:user_checking])
    render_wizard(@user_checking)
  end

  def save_license
    shop_auth_params = params[:shop_auth]
    shop_params = shop_auth_params[:shop].merge(
      address_id: @user_checking.address.try(:id))
    if current_user.shop.blank?
      @shop = @user_checking.user.create_shop(shop_params)
    else
      @user_checking.user.shop.update_attributes(shop_params)
    end
    shop_auth_params.delete(:shop)
    @shop_auth = ShopAuth.new(shop_auth_params.merge(user_id: @user_checking.user.id))
    if @shop_auth.valid?
      @user_checking.update_attributes(@shop_auth.update_options.merge(rejected: false))
      render_wizard(@user_checking)
    else
      render_wizard
    end
  end

  def set_products_added
    @user_checking.update_attributes(products_added: true)
    # 添加服务（是否有服务是主页跳转到选择服务选择页的判断标记）
    current_user.services << Service.where(service_type: "seller")
    redirect_to '/'
  end
end
