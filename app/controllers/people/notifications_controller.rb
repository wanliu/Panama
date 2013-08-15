#describe: 提醒控制器
class People::NotificationsController < People::BaseController
    before_filter :login_and_service_required

    def index      
      authorize! :index, Notification
      @notifications = Notification
      unless params[:all] == "1"
          @notifications = Notification.unreads
      end
      @notifications = @notifications.where(:user_id => @people.id)
      .order(read: :asc)      
      respond_to do | format |
          format.html
          format.json{ render json: @notifications}
      end
    end

    def show
      @notification = Notification.find_by(:user_id => @people.id, :id => params[:id])
      respond_to do | format |
          unless @notification.nil?
              authorize! :read, @notification
              @notification.update_attribute(:read, true)
              format.html{ redirect_to @notification.url }
          else
              format.html{ redirect_to person_notifications_path(@people.login) }
          end
      end
    end

    def read_notification
      @notification = Notification.find_by(:user_id => params[:person_id], :id => params[:id])
      authorize! :read, @notification
      @notification.update_attribute(:read, true)
      render nothing: true
    end

    def unread
      @notifications = Notification.unreads.where({ 
        :mentionable_user_id => current_user.id, 
        :targeable_type => params[:type] }).includes(:targeable)
      respond_to do |format|
        format.json { render json: Notification.format_unreads(@notifications) }
      end
    end
end