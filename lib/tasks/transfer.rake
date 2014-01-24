#encoding: utf-8

namespace :transfer do 
  desc "重新统计库存"
  task :init => :environment do 
    ShopProduct.all.each{|s| s.recount_inventory }
  end
end