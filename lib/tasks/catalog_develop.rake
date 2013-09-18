namespace :catalog_develop do
  desc "create catalog"
  task :load => :environment do
    catalogs = YAML::load_file("#{Rails.root}/config/data/catalog_init.yml")
    catalogs["catalog"].each do | item |
    	catalog = Catalog.create(:title => item["title"])
    	catalog.categories << Category.where(:id => item["categories_id"])
    end
  end
end