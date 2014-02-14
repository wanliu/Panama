#encoding: utf-8
namespace :change_services do
  desc "old service already changed and this will fill your services blank"
  task :load => :environment do
    User.all.each do |u|
      if u.services.blank? 
        unless u.try(:shop).nil?
          u.update_attribute("services","seller")
          if u.user_checking.nil?
            u.create_user_checking(:service => "seller")
          end
          u.user_checking.update_attribute("service","seller")
        else
          u.update_attribute("services","buyer")
          if u.user_checking.nil?
            u.create_user_checking(:service => "buyer")
          end
          u.user_checking.update_attribute("service","buyer")
        end
      end
    end
  end
end