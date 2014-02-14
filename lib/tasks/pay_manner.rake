namespace :pay_manner do
  desc "load define pay manner"
  task :load => :environment do
    pay_manners = YAML::load_file("#{Rails.root}/config/data/pay_manner.yml")["pay_manner"]
    pay_manners.each do | item |
    	PayManner.create(item)
    end
  end
end