class Admins::Shops::ShopProductsController < Admins::Shops::SectionController

  def index
    @products = current_shop.try(:shop_products) || []
  end
end