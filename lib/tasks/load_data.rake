# require :File.expand_path('../../config/environment',  __FILE__)

namespace "shop" do
  desc "load some shop data"
  task :load, [:shop_name] => :environment do |t, args|
    shop = Shop.where(:name => args[:shop_name]).first
    shop.send :create_shop
    shop.send :initial_shop_data
  end
end
