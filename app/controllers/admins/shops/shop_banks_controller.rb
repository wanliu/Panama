
class Admins::Shops::ShopBanksController < Admins::Shops::SectionController

  def index
    @shop_banks = current_shop.banks
  end

  def create
    @shop_bank = current_shop.banks.create(params[:shop_bank])
    respond_to do |format|
      format.html{ redirect_to shop_admins_shop_banks_path(current_shop) }
    end
  end
end