namespace :transaction do
  desc "clean error transaction"
  task :clear => :environment do
  	dids = DirectTransaction.all.map{ |d| d.id if d.items.blank? }.compact
  	oids = OrderTransaction.all.map { |o| o.id if o.items.blank?  }.compact
  	DirectTransaction.where(:id => dids).destroy_all
  	OrderTransaction.where(:id => oids).destroy_all
  end
end
