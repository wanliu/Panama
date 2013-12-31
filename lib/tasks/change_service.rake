#encoding: utf-8
namespace :change_services do
  desc "old service already changed and this will fill your services blank"
  task :load => :environment do
    User.all.each do |u|
    	if u.services.nil? 
        unless u.try(:shop).nil?
      		u.update_attribute("services","seller")
      		u.user_checking.update_attribute("service","seller")
      	else
      		u.update_attribute("services","buyer")
      		u.user_checking.update_attribute("service","buyer")
        end
    	end
    end
  end
end