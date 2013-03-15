# require :File.expand_path('../../config/environment',  __FILE__)

namespace "permission" do
  desc "load define permission"
  task :load => :environment do |t, args|
    permissions = YAML::load_file("#{Rails.root}/config/permission.yml")["permission"]
    permissions.each do | permission |
        key = permission.keys.first
        Permission.define(key, permission[key])
    end
  end
end
