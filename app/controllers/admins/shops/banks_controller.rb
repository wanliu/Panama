class Admins::Shops::BanksController < Admins::Shops::SectionController

  def index
  end

  def create
    @user_bank = current_shop.user.banks.new(params[:bank])
    respond_to do |format|
      if @user_bank.save
        format.html{
          render :partial => "people/banks/item", :locals => { :user_bank => @user_bank } }        
      else
        format.json{
          render :json => draw_errors_message(@user_bank), :status => 403  }
      end
    end
  end
end