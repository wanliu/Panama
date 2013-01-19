class ApplicationController < ActionController::Base
  include ApplicationHelper
  include OmniAuth::Wanliu::AjaxHelpers 

  protect_from_forgery
  
  layout 'bootstrap'
  
  helper_method :current_user

  def login_required    
    if !current_user
      respond_to do |format|
        format.js{
          ajax_set_response_headers
          render :js => :ok }
        format.html  {
          redirect_to '/auth/wanliuid' }
        format.json {
          render :json => { 'error' => 'Access Denied' }.to_json  }
      end
    end
  end

  def load_category
    @category_root = Category.where(:name => "_products_root").first
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
  protected
end
