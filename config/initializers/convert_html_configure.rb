require File.expand_path("lib/text_format_html", Rails.root)

module TextFormatHtml
  module Configure

    def self.included(base)
      base.class_eval do
        include TextFormat::Html

        define_format_rule(/@(\w{3,20})/) do |mh|
          login = mh[1]
          user = User.find_by(login: login)
          user.nil? ? "@#{login}" : "<a href='/users/#{user.id}'>@#{login}</a>"
        end
      end
    end

  end
end