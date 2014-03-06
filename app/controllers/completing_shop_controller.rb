class CompletingShopController < Wicked::WizardController
  layout "wizard"
  before_filter :login_required_without_service_seller

  steps :pick_industry, :authenticate_license, :pick_product

  def show
    @user_checking = current_user.user_checking || UserChecking.where(:service => "seller", :user_id => current_user.id).first_or_create

    the_shop          = @user_checking.user.shop
    shop_auth_options = @user_checking.attributes
    if !the_shop.blank?
      shop_auth_options = shop_auth_options.merge({
        "shop_name" => the_shop.name,
        "shop_summary" => the_shop.shop_summary
      })
    end
    @shop_auth = ShopAuth.new(shop_auth_options)

    if @user_checking.checked && current_user.try(:shop).try(:actived)
      redirect_to "/"
    else
      case step
      when :pick_product
        @products = ShopProduct
          .joins(:product)
          .select(["shop_products.*", "products.name"])
          .where("shop_products.shop_id = ? ", current_user.shop.id)
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
    @user_checking.unchecked
    shop_auth_params = params[:shop_auth]

    @shop_auth = ShopAuth.new(shop_auth_params.merge(
      user_id: @user_checking.user.id
    ))

    if @shop_auth.valid?
      shop_params = {
        name: shop_auth_params[:shop_name],
        shop_summary: shop_auth_params[:shop_summary],
        address_id: @user_checking.address.try(:id),
        photo: @user_checking.shop_photo
      }

      begin
        if current_user.shop.blank?
          @user_checking.transaction do
            current_user.create_shop(shop_params).save!
            @user_checking.update_attributes!(@shop_auth.update_options.merge(rejected: false))
          end
        else
          @user_checking.transaction do
            current_user.shop.update_attributes!(shop_params)
            @user_checking.update_attributes!(@shop_auth.update_options.merge(rejected: false))
          end
        end
      rescue
        @shop_auth.valid?
        render_wizard
      end

      render_wizard(@user_checking) unless performed?
    else
      render_wizard
    end
  end

  def set_products_added
    @user_checking.update_attributes(products_added: true)
    # 添加服务（是否有服务是主页跳转到选择服务选择页的判断标记）
    current_user.add_service "seller"
    current_user.save
    redirect_to '/'
  end
end
