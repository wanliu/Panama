class ApplicationController < ActionController::Base
  include ApplicationHelper
  include OmniAuth::Wanliu::AjaxHelpers

  protect_from_forgery

  layout 'bootstrap'

  has_widgets do |root|
    root << widget(:cart, :my_cart)
    root << widget(:notification)
    root << widget(:chat)
  end

  helper_method :current_user, :current_admin, :my_cart, :get_city

  before_filter :set_locale

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def draw_errors_message(ist_model)
    messages = []
    ist_model.errors.messages.each do |attr, ms|
      ms.each{| m | messages << "#{attr}: #{m}"}
    end
    messages
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # 绑定登陆和服务选择(买家，卖家？)
  def login_required
    if !current_user

      respond_to do |format|
        format.js{
          ajax_set_response_headers
          render :text => :ok, :status => 403 }
        format.html  {
          configure_callback_url
          redirect_to '/auth/wanliuid' }
        format.json {
          render :json => { 'error' => 'Access Denied' }.to_json  }
      end
    elsif current_user.services.empty?
      respond_to do |format|
        format.js{
          ajax_set_response_headers
          render :text => :ok, :status => 403 }
        format.html  {
          @user = current_user
          redirect_to "/after_signup" }
        format.json {
          render :json => { 'error' => '您尚未选择服务' }.to_json  }
      end
    end
  end

  def admin_required
    if !current_admin

      respond_to do |format|
        format.html  {
          configure_callback_url
          redirect_to '/auth/wanliuadminid' }
        format.json {
          render :json => { 'error' => 'Access Denied' }.to_json  }
      end
    end
  end

  def login_or_admin_required
    if !current_user && !current_admin
      login_required
    end
  end

  def configure_callback_url
    url = "http://#{request.env['HTTP_HOST']}#{request.env["PATH_INFO"]}"
    session[:auth_redirect] = url
  end

  def auth_redirect
    session[:auth_redirect] || root_path
  end

  def load_category
    @category_root = Category.where(:name => "_products_root")[0]
  end

  def self.admin
    self.class_eval <<-RUBY
      def admin?
        true
      end

      def admin_path
        File.join(url_for,"admins")
      end
    RUBY
  end

  def generate_auth_string
    now = DateTime.now
    r1, r2 = rand(999), rand(999)
    Crypto.encrypt("#{now}|#{r1}|#{r2}|#{r1+r2}")
  end

  #验证算法,但是没有验证生效日期
  def validate_auth_string(auth_string)
    auth = Crypto.decrypt(auth_string) rescue nil
    return false if auth.nil?
    time, r1, r2, result = auth.split("|")
    return false unless r1.to_i + r2.to_i == result.to_i
    DateTime.parse(time)
  end

  def get_city
    City.first && City.first.children || []
  end
  protected
end
