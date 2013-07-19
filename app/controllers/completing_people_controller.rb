class CompletingPeopleController < Wicked::WizardController
  layout "wizard"

  steps :pick_industry, :authenticate_license, :waiting_audit

  def show
  	@user_auth = UserAuth.new

  	service_id = Service.where(service_type: "buyer").first.id
  	# @user_checking = UserChecking.create(user_id: user_id, service_id: service_id)
  	@user_checking = current_user.user_checking || current_user.create_user_checking(service_id: service_id)

    render_wizard
  end

  def update
    @user_checking = current_user.user_checking
    case step
    when :pick_industry
      save_industry_type
  	when :authenticate_license
      save_license
    when :waiting_audit

    end
  end

  private
  def save_industry_type
    @user_checking.update_attributes(params[:user_checking])
  	render_wizard(@user_checking)
  end

  def save_license
    @user_auth = UserAuth.new(params[:user_auth])
    if @user_auth.valid?
      next_step
    end
    render_wizard
  end
end
