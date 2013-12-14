namespace "order" do
  desc "generate order number"
  task :generate_number => :environment do |t, args|
    OrderTransaction.all.each do |ot|
      ot.number = "#{'0' * (9-ot.id.to_s.length)}#{ot.id}"
      ot.save
    end
  end
end

namespace "direct_order" do
  desc "generate order number"
  task :generate_number => :environment do |t, args|
    DirectTransaction.all.each do |dt|
      dt.number = "D#{'0' * (9-dt.id.to_s.length)}#{dt.id}"
      dt.save
    end
  end
end

namespace "order_refund" do
  desc "generate order refund number"
  task :generate_number => :environment do |t, args|
    OrderRefund.all.each do |dt|
      dt.number = "#{'0' * (9-dt.id.to_s.length)}#{dt.id}"
      dt.save
    end
  end
end