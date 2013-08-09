#encoding: utf-8
namespace :delivery_type do
  desc "load seed data of delivery type"
  task :load => :environment do
    DeliveryType.create( :name => "EMS", :price => 8, :description => "网点全，速度较快，价格较高")
    DeliveryType.create( :name => "快递", :price => 6, :description => "一般3到4天时间，价格适中")
    DeliveryType.create( :name => "平邮", :price => 4, :description => "价格低，时间长，网点全")
  end
end