#encoding: utf-8

class UserMailer < ActionMailer::Base
  default from: "huxinghai1988@163.com"

  def invite_employee(to, user, shop, url)
    @user, @shop, @url= user, shop, url
    mail(:to => to, :subject => "[Panama] 邀请通知信息")
  end
end
