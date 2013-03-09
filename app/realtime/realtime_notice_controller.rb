class RealtimeNoticeController < FayeRails::Controller
    observe Notification, :after_create do |notice|
    	puts "notice: #{notice.user.login}"
        RealtimeNoticeController.publish("/notification/#{notice.user.login}", notice.attributes)
    end
end