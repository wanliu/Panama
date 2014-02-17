require File.expand_path("lib/text_format_html", Rails.root)

module TextFormatHtml
  module Configure

    def self.included(base)
      base.class_eval do
        include TextFormat::Html

        define_format_rule(/@(\w{3,20})/) do |login|
          if login.present?
            login.slice!(0)
            user = User.find_by(login: login)
            login = "@#{login}"
            if user.present?
              login = "<a href='/users/#{user.id}'>#{login}</a>"
            end
            login
          end
        end
      end
    end

  end
end