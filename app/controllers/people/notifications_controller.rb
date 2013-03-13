class People::NotificationsController < People::BaseController

    def index
        @notifications = Notification
        unless params[:all] == "1"
            @notifications = Notification.unreads
        end
        @notifications = @notifications.where(:user_id => @people.id)
        respond_to do | format |
            format.html
            format.json
        end
    end

    def show
        @notification = Notification.find_by(:user_id => @people.id, :id => params[:id])

        respond_to do | format |
            unless @notification.nil?
                @notification.update_attribute(:read, true)
                format.html{ redirect_to @notification.url }
            else
                format.html{ redirect_to person_notifications_path(@people.login) }
            end
        end
    end
end