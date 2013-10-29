namespace :circle do
  desc "load circle manage user"
  task :load => :environment do
  	Circle.all.each do |c|
  		c.generate_manage
  	end
  end
end