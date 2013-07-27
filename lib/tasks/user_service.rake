#encoding: utf-8
namespace :user_services do
  desc "load seed data of user services"
  task :load => :environment do
    Service.create!(:name => "零售商", :service_type => "buyer") if Service.where(:service_type => "buyer").blank?
    Service.create!(:name => "批发商", :service_type => "seller") if Service.where(:service_type => "seller").blank?
  end
end