# Change this omniauth configuration to point to your registered provider
# Since this is a registered application, add the app id and secret here
#

# APP_ID = 'YE0NYveQGoFsNLX220Dy5g'
# APP_SECRET = 'aqpGBedDnHFyp5MmgT8KErr9D015ScmaY8r3vHg5C0'

# CUSTOM_PROVIDER_URL = 'http://localhost:3000'
info = OmniAuth::Wanliu.config
require 'wanliu_system_id'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :wanliu_id, info["app_id"], info["app_secret"]
  provider :wanliu_admin_id, info["app_id"], info["app_secret"]
end
