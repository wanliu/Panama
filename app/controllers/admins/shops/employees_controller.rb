#encoding: utf-8
class Admins::Shops::EmployeesController < Admins::Shops::SectionController

    def index
        @groups = ShopGroup.where(:shop_id => current_shop.id)
        @employees = current_shop.employee_users
    end

    def invite
        @user = User.find_by(:login => params[:login])
        shop_name = encrypt(current_shop.name)

        respond_to do |form|
            if @user
                login = encrypt(@user.login)
                url = "/shops/#{shop_name}/show_invite/#{login}?auth=#{generate_auth_string}"
                Notification.create!(
                    :user_id => @user.id,
                    :mentionable_user_id => current_user.id,
                    :url => url,
                    :body => "#{current_shop.name} 商店邀请你加入")
                form.json{ render :json => {message: "已经发送信息给对方了，等待同意！"} }
            else
                email = params[:login]
                url = "/shops/#{shop_name}/show_email_invite?auth=#{generate_auth_string}"
                #如果email发送信息给它
                if email =~ email_match
                    UserMailer.invite_employee(email, current_user,
                        current_shop, email_invite_url(url)).deliver
                    form.json{ render :json => {message: "已经发送邀请邮件给对方了，等待同意！"} }
                else
                    form.json{ render :text => "用户不存在！",:status => 403 }
                end
            end
        end
    end

    private
    def email_invite_url(url)
        "#{accounts_provider_url}/accounts/login?redirect_uri=http://#{request.env['HTTP_HOST']}#{url}"
    end

    def email_match
        /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    end

    def encrypt(val)
        Crypto.encrypt(val)
    end
end