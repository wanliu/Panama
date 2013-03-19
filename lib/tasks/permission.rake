# require :File.expand_path('../../config/environment',  __FILE__)

namespace "permission" do
  desc "load define permission"
  task :load => :environment do
    permissions = YAML::load_file("#{Rails.root}/config/permission.yml")["permission"]
    permissions.each do | key, vals |
        Permission.define(key, vals)
    end
  end
end

# namespace "group:permission" do
#     desc "load group permission"
#     task :load => :environment do
#         group_permissions = YAML::load_file("#{Rails.root}/config/permission.yml")["group_permission"]
#         group_permissions.each do | group, permissions |
#             ShopGroup.give_permission(group, permissions)
#         end
#     end
# end
