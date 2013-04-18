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

  namespace "test" do
    desc "load product data from mongo to mysql,args[:mongo_host, :mongo_dbname]"
    task :load_product_from_mongo, [:mongo_host, :mongo_dbname] => :environment do |t, args|
      puts "----------------begin--------------------"
      shop_id = Shop.first.id
      shops_category_id = ShopsCategory.first.id

      MYSQL_OPTION = {
        :host => "localhost",
        :username => "root",
        :password => "",
        :database => "panama_development"
      }

      MONGO_OPTION = {
        :host => args[:mongo_host] || "127.0.0.1",
        :database => args[:mongo_dbname] || "neza_public_development",
        :port => "27017"
      }
      mysql_db = Mysql2::Client.new(MYSQL_OPTION)
      mongo_db = Moped::Session.new([MONGO_OPTION[:host]+":27017"]).use(MONGO_OPTION[:database])
      products = mongo_db["products"].find
      
      if products.count > 0
        sql_insert = ""
        products.each do |slice|
          category_id = slice["product_category_id"] || "null"
          sql_insert = "insert into products (shop_id, shops_category_id, name, price, category_id) values(#{shop_id}, #{shops_category_id}, \"#{slice["name"]}\", #{slice["price"]}, #{category_id});"
          print "."
          mysql_db.query(sql_insert)
        end
      end
      puts "----------------end--------------------"
    end
  end
end