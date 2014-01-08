
class People::BanksController < People::BaseController

  def index
  end

  def create
    @user_bank = current_user.banks.new(params[:bank])
    respond_to do |format|
      if @user_bank.save
        format.html{
          render :partial => "item", :locals => { :user_bank => @user_bank } }        
      else
        format.json{
          render :json => draw_errors_message(@user_bank), :status => 403  }
      end
    end
  end
end