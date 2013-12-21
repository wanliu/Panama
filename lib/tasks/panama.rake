require 'panama_core'
require 'yaml'
require 'fileutils'

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

  def database_config
    @config ||= YAML.load_file(File.expand_path("../../../config/database.yml", __FILE__))
  end

  def mysql_export(table)

    env = ENV['RAILS_ENV'] || 'development'


    adapter = database_config[env]['adapter']
    throw 'database.yml must use mysql adapter' unless adapter =~ /mysql/

    database = database_config[env]['database']
    user = database_config[env]['username']
    pass = database_config[env]['password']
    out_path = File.expand_path('../../../tmp/sql', __FILE__)
    out_file = File.join(out_path, table + '.sql')

    pass_arg = pass.nil? || pass.empty? ? '' : pass

    FileUtils.mkdir_p out_path
    `mysqldump -u #{user} #{pass_arg} #{database} #{table} > #{out_file}`
    print '.'
  end

  def mysql_import(table)

    env = ENV['RAILS_ENV'] || 'development'


    adapter = database_config[env]['adapter']
    throw 'database.yml must use mysql adapter' unless adapter =~ /mysql/

    database = database_config[env]['database']
    user = database_config[env]['username']
    pass = database_config[env]['password']
    in_path = File.expand_path('../../../tmp/sql', __FILE__)
    in_file = File.join(in_path, table + '.sql')

    puts in_file
    pass_arg = pass.nil? || pass.empty? ? '' : pass

    `mysql -u #{user} #{pass_arg} #{database} < #{in_file}`
    print '.'
  end

  namespace "export" do

    desc "exports product tables to sql files"
    task "products" do
      env = ENV['RAILS_ENV'] || 'development'
      puts "exporting #{env} environment data."

      mysql_export('categories')
      mysql_export('categories_properties')
      mysql_export('products')
      mysql_export('properties')
      mysql_export('property_items')
      mysql_export('property_values')
      mysql_export('products_properties')
      mysql_export('products_property_items')
      mysql_export('product_prices')
      mysql_export('product_prices_property_items')
      mysql_export('price_options')
      mysql_export('attachments')
    end

  end

  namespace "import" do

    desc "import from sql files to product tables"
    task "products" do
      env = ENV['RAILS_ENV'] || 'development'
      puts "importing #{env} environment data."

      mysql_import('categories')
      mysql_import('categories_properties')
      mysql_import('products')
      mysql_import('properties')
      mysql_import('property_items')
      mysql_import('property_values')
      mysql_import('products_properties')
      mysql_import('products_property_items')
      mysql_import('product_prices')
      mysql_import('product_prices_property_items')
      mysql_import('price_options')
      mysql_import('attachments')
    end
  end
end