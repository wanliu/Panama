#encoding: utf-8

class UserMailer < ActionMailer::Base
  default from: "huxinghai1988@163.com"

  def invite_employee(to, user, shop, url)
    @user, @shop, @url= user, shop, url
    mail(:to => to, :subject => "[Panama] 邀请通知信息")
  end

  def send_user_checked_notify(user_mail, user_name, url)
  	@user_name, @url = user_name, url
    mail(:to => user_mail, :subject => "[万流商城] 您的验证申请已经通过审核")
  end

  def send_user_rejected_notify(user_mail, user_name, rejected_reason, url)
  	@user_name, @rejected_reason, @url = user_name, rejected_reason, url
    mail(:to => user_mail, :subject => "[万流商城] 您的验证申请没有通过审核")
  end


  def send_activity_checked_notify(user_mail, user_name, url)
    @user_name, @url = user_name, url
    mail(:to => user_mail, :subject => "[万流商城] 您的发布活动申请已经通过审核")
  end

  def send_activity_rejected_notify(user_mail, user_name, rejected_reason, url)
    @user_name, @rejected_reason, @url = user_name, rejected_reason, url
    mail(:to => user_mail, :subject => "[万流商城] 您的发布活动申请没有通过审核")
  end
end
