namespace :delivery_manner do
  desc "load define delivery manner"
  task :load => :environment do
    delivery_manners = YAML::load_file("#{Rails.root}/config/data/delivery_manner.yml")["delivery_manner"]
    delivery_manners.each do | item |
        DeliveryManner.create(item)
    end
  end
end