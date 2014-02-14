#author: huxinghai
#describe: 提取内容中@用户

module Extract
  module Mention
    def self.included(base)
      base.extend(ClassMethod)
    end

    module ClassMethod
      def extract_attributes(*attributes)
        attributes.each do | attr |
          self.instance_eval do
            define_method "#{attr}_extract_users" do
              extract_login attr
            end
          end
        end
      end
    end

    private
    def extract_login(attr)
      logins = self.send(attr).scan(/@(\w{3,20})/).flatten
      User.where(:login => logins)
    end
  end
end