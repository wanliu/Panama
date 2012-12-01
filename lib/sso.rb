sso = YAML.load_file(Rails.root.join('config/sso.yml').to_s)
sso['accounts'].map do |key, value|
  Rails.application.config.send("sso_#{key}=".to_sym, value)
end
# Rails.application.config.sso.provider_url = sso['accounts']['url']
# Rails.application.config.sso.app_id       = sso['accounts']['app_id']
# Rails.application.config.sso.app_secret   = sso['accounts']['app_secret']