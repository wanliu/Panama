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
        # :host => "192.168.2.120",
        # :database => "neza_public_development",
        :host => args[:mongo_host],
        :database => args[:mongo_dbname],
        :port => "27017"
      }
      
      mysql_db = Mysql.init
      mysql_db.options(Mysql::SET_CHARSET_NAME,"utf8")
      mysql_db = Mysql.real_connect(MYSQL_OPTION[:host], MYSQL_OPTION[:username], MYSQL_OPTION[:password], MYSQL_OPTION[:database])
      mysql_db.query("SET NAMES utf8")

      mong_cn = Mongo::Connection.new(MONGO_OPTION[:host],MONGO_OPTION[:port])
      mong_db = mong_cn.db(MONGO_OPTION[:database])
      products = mong_db.collection("products").find
      
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