class WelcomeController < ApplicationController
  before_filter :login_and_service_required

end
