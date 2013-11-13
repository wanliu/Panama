#encoding: utf-8
namespace :circle do
  desc "load circle manage user"
  task :load => :environment do
    Circle.all.each do |c|
      c.generate_manage
    end
  end
end

namespace :circle_category do
  desc "create a default circle_category"
  task :load => :environment do
    Circle.all.each do |c|
      if c.categories.length < 1
      	c.categories.create(:name => "分享")
      end
    end
  end
end