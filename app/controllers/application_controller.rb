class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery
  
  layout 'bootstrap'
  
  helper_method :current_user

  def login_required
    if !current_user
      respond_to do |format|
        format.html  {
          redirect_to '/auth/wanliuid'
        }
        format.json {
          render :json => { 'error' => 'Access Denied' }.to_json
        }
      end
    end
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
