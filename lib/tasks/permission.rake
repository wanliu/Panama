# require :File.expand_path('../../config/environment',  __FILE__)

namespace "permission" do
  desc "load define permission"
  task :load => :environment do
    permissions = YAML::load_file("#{Rails.root}/config/data/permission.yml")["permission"]
    permissions.each do | key, vals |
        Permission.define(key, vals)
    end
  end
end