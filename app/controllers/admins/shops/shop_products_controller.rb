class Admins::Shops::ShopProductsController < Admins::Shops::SectionController

  def index
    @products = current_shop.try(:products) || []
  end
end