class CompletingPeopleController < Wicked::WizardController
  layout "wizard"

  steps :pick_industry, :authenticate_license#, :waiting_audit

  def show
  	service_id = Service.where(service_type: "buyer").first.id
  	@user_checking = current_user.user_checking || current_user.create_user_checking(service_id: service_id)
    @user_auth = UserAuth.new(@user_checking.attributes)
    render_wizard
  end

  def update
    @user_checking = current_user.user_checking
    case step
    when :pick_industry
      save_industry_type
  	when :authenticate_license
      save_license
    # when :waiting_audit
    end
  end

  def skip
    case step
    when :authenticate_license
      skip_authenticate_license
    end
  end

  private
    def save_industry_type
      @user_checking.update_attributes(params[:user_checking])
    	render_wizard(@user_checking)
    end

    def save_license
      @user_auth = UserAuth.new(params[:user_auth].merge(user_id: @user_checking.user.id))
      if @user_auth.valid?
        @user_checking.update_attributes(@user_auth.update_options)

        current_user.services << Service.where(service_type: @user_checking.service.service_type)

        # render_wizard(@user_checking)
        redirect_to '/'
      else
        render_wizard
      end
    end

    def skip_authenticate_license
      user_checking = current_user.user_checking
      current_user.services << Service.where(service_type: user_checking.service.service_type)
      redirect_to '/'
    end
end
