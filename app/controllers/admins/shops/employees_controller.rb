#encoding: utf-8
class Admins::Shops::EmployeesController < Admins::Shops::SectionController

    def index
        @groups = ShopGroup.where(:shop_id => current_shop.id)
        @employees = current_shop.employee_users
    end

    def invite
        @user = User.find_by(:login => params[:login])
        shop_name = Crypto.encrypt(current_shop.name)
        login = Crypto.encrypt(@user.login)
        now = Crypto.encrypt(DateTime.now)
        url = "/shops/#{shop_name}/show_invite/#{login}?date=#{now}"
        respond_to do |form|
            if @user
                Notification.create!(
                    :user_id => @user.id,
                    :mentionable_user_id => current_user.id,
                    :url => url,
                    :body => "#{current_shop.name} 商店邀请你加入")
                form.json{ render :json => {message: "已经发送信息给对方了，等待同意！"} }
            else
                #如果email发送信息给它
                if params[:login] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
                    url = "http://192.168.2.31/login?redirect_uri=#{request.env['HTTP_HOST']}#{url}"
                    UserMailer.invite_employee(params[:login], current_user,
                        current_shop, url)
                    form.json{ render :json => {message: "已经发送邀请邮件给对方了，等待同意！"} }
                else
                    form.json{ render :text => "用户不存在！",:status => 403 }
                end
            end
        end
    end
end