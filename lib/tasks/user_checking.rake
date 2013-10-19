#encoding: utf-8
namespace :user_checking do
  desc "load user checking data"
  task :load => :environment do
    ucs = UserChecking.all
    state = Address.columns_hash.has_key?("targeable_id")
    ucs.each do |uc|
      if uc.service.name == "商家"
        uc.owner = uc.user.try(:shop)
      else
        uc.owner = uc.user
      end
      if state
        uc.address_id = Address.find_by(
          :targeable_id => uc.id,
          :targeable_type => "UserChecking").try(:id)
      end
      uc.save
    end
  end
end