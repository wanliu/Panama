#describe: 提醒控制器
class People::NotificationsController < People::BaseController
  before_filter :login_and_service_required

  def index      
    authorize! :index, Notification
    @notifications = Notification.unreads
        .where(:mentionable_user_id => @people.id)
        .order(updated_at: :asc)   
    respond_to do | format |
      format.html
      format.json{ render json: @notifications}
    end
  end

  def show
    @notification = Notification.find_by(:mentionable_user_id => @people.id, :id => params[:id])
    respond_to do | format |
      unless @notification.nil?
        authorize! :read, @notification
        @notification.update_attribute(:read, true)
        format.html{ redirect_to @notification.url }
        format.json{ head :no_content }
      else
        format.html{ redirect_to person_notifications_path(@people.login) }
      end
    end
  end

  def mark_as_read
    @notification = Notification.find(params[:id])
    authorize! :read, @notification
    @notification.update_attribute(:read, true)
    respond_to do | format |
      format.json { head :no_content }
    end
  end

  def unreads
    @notifications = Notification.unreads
        .where(:mentionable_user_id => @people.id)
        .order(updated_at: :asc)
        .includes(:targeable)
    respond_to do |format|
      format.json { render json: @notifications.format_unreads(@notifications) }
    end
  end
end