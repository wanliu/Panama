module People::NotificationsHelper

  def checked_button(notification)
    if notification.read
      ""
    else
      link_to icon(:check)
    end
  end
end