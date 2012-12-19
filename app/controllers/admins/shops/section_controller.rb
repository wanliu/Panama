class Admins::Shops::SectionController < Admins::BaseController
  before_filter :current_shop

  section :dashboard
  section :contents


  def current_shop
    @current_shop = Shop.find(params[:shop_id])
  end
end