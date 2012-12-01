# Change this omniauth configuration to point to your registered provider
# Since this is a registered application, add the app id and secret here
# 
require 'sso'
app_id       = Rails.application.config.sso_app_id
app_secret   = Rails.application.config.sso_app_secret
# APP_ID = 'YE0NYveQGoFsNLX220Dy5g'
# APP_SECRET = 'aqpGBedDnHFyp5MmgT8KErr9D015ScmaY8r3vHg5C0'

# CUSTOM_PROVIDER_URL = 'http://localhost:3000'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :wanliu_id, app_id, app_secret
end
