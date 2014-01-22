#encoding: utf-8

namespace :transfer do 
  desc "重新统计库存"
  task :init => :environment do 
    ShopProduct.all.each do |s|
      s.update_column(:inventory, s.transfers.sum(:amount))
    end
  end
end