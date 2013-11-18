require 'omniauth-oauth2'

module OmniAuth
    module Strategies
        class WanliuAdminId < OmniAuth::Strategies::OAuth2

            # option :iframe, true

            option :callback_path, '/auth/admin/wanliu_admin_id/callback'

            server_addr = OmniAuth::Wanliu.config["provider_url"]

            # This is where you pass the options you would pass when
            # initializing your consumer from the OAuth gem.
            option :client_options, {
                :site => server_addr,
                :token_url => 'oauth/admin/token' ,
                :authorize_url => "#{server_addr}/auth/wanliu_admin_id/authorize",
                :access_token_url => "#{server_addr}/auth/wanliu_admin_id/access_token"
            }

            option :provider_ignores_state, true

            # These are called after authentication has succeeded. If
            # possible, you should try to set the UID without making
            # additional calls (if the user id is returned with the token
            # or as a URI parameter). This may not be possible with all
            # providers.
            uid{ raw_info['id'] }

            info do
            {
              :name => raw_info["info"]['name'],
              :email => raw_info["info"]['email'],
              :login => raw_info["info"]["login"],
              :avatar => raw_info["info"]["avatar"]
            }
            end

            extra do
            {
              'raw_info' => raw_info
            }
            end

            def raw_info
                @raw_info ||= access_token.get("/auth/wanliu_admin_id/user.json?oauth_token=#{access_token.token}").parsed
            end
        end
    end
end