class Admins::Shops::ShopProductsController < Admins::Shops::SectionController

	def index
    @products = current_user.shop.try(:shop_products) || []
  end
end