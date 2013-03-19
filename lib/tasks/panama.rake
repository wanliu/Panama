require 'panama_core'

namespace "panama" do
  namespace :vfs do
    desc "load panama files to vfs"
    task :load => :environment do
      PanamaCore::VFS.load_panama_files
    end

    desc "clear panama files in vfs"
    task :clear => :environment do
      PanamaCore::VFS.clear_panama_files
    end
  end

  namespace :category do
    desc "load panama product categories"
    task :load => :environment do
      @root = Category.root
      product_category_file = Rails.root.join("config/product_category.yml")
      @root.load_file(product_category_file)
    end

    desc "clear panama categories"
    task :clear => :environment do
      @root = Category.root
      @root.clear_categories
    end
  end
end