class RealtimeNoticeController < FayeRails::Controller
    observe Notification, :after_create do |notice|
        RealtimeNoticeController.publish("/notification/#{notice.user.login}", notice.attributes)
    end
end