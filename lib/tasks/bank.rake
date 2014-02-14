namespace :bank do
  desc "load bank data"
  task :load => :environment do
    bank_file = Rails.root.join("config/bank.yml")
    Bank.load_file(bank_file)
  end
end