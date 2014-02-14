namespace :order_reason do
  desc "load order reason data"
  task :load => :environment do
    reasons = YAML::load_file("#{Rails.root}/config/data/order_reason.yml")["order_reason"]
    reasons.each do |reason|
      puts reason
      OrderReason.create(reason)
    end
  end
end