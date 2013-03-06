class ApplicationController < ActionController::Base
  include ApplicationHelper
  include OmniAuth::Wanliu::AjaxHelpers

  protect_from_forgery

  layout 'bootstrap'

  has_widgets do |root|
    root << widget(:cart, :my_cart)
    root << widget(:notification)
  end

  helper_method :current_user, :current_admin, :my_cart, :get_city

  before_filter :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def login_required
    if !current_user

      respond_to do |format|
        format.js{
          ajax_set_response_headers
          render :text => :ok, :status => 403 }
        format.html  {
          redirect_to '/auth/wanliuid' }
        format.json {
          render :json => { 'error' => 'Access Denied' }.to_json  }
      end
    end
  end

  def admin_required
    if !current_admin

      respond_to do |format|
        format.html  {
          redirect_to '/auth/wanliuadminid' }
        format.json {
          render :json => { 'error' => 'Access Denied' }.to_json  }
      end
    end
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

  def get_city
    City.first && City.first.children || []
  end
  protected
end
