class CompletingPeopleController < Wicked::WizardController
  layout "sigin"

  steps :pick_industry, :authenticate_license, :waiting_audit

  def show
  	@user_auth = UserAuth.new
    render_wizard
  end

  def update
    case step
    when :pick_industry
      
  	when :authenticate_license
      save_license
    when :waiting_audit

    end
  end

  private
  def save_license
    @user_auth = UserAuth.new(params[:user_auth])
    if @user_auth.valid?
      next_step
    end
    render_wizard
  end
end
