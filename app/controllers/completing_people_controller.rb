class CompletingPeopleController < Wicked::WizardController
  layout "wizard"
  before_filter :login_required_without_service_choosen
  before_filter :validate_step_info, :only => :show

  steps :pick_industry, :authenticate_license#, :waiting_audit

  def show
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
      if @user_checking.industry_type.blank?
        @user_checking.update_attributes(params[:user_checking])
      end
      render_wizard(@user_checking)
    end

    def save_license
      @user_auth = UserAuth.new(params[:user_auth].merge(user_id: @user_checking.user.id))
      if @user_auth.valid?
        @user_checking.update_attributes(@user_auth.update_options)

        current_user.services << Service.buyer

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

    def validate_step_info
      @user_checking = current_user.user_checking || current_user.create_user_checking(service_id: Service.buyer.id)
      case step
      when :pick_industry
        if @user_checking.industry_type.present?
          redirect_to '/completing_people/authenticate_license'
        end
      end
    end
end
