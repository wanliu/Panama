#encoding: utf-8

namespace :city do
  desc 'city  mysql to mongo'
  task :mysql_to_mongo => :environment do
    MYSQL_OPTION = {
        :host => "localhost",
        :user_name => "root",
        :password => "",
        :database_name_mysql => "test"
    }

    MONGO_OPTION = {
      :host => "localhost",
      :database_name => "panama_development",
      :port => "27017"
    }

    puts "----------------begin--------------------"
    sql = Mysql.init
    sql.options(Mysql::SET_CHARSET_NAME,"utf8")
    sql = Mysql.real_connect(MYSQL_OPTION[:host], MYSQL_OPTION[:user_name], MYSQL_OPTION[:password], MYSQL_OPTION[:database_name_mysql])
    sql.query("SET NAMES utf8")

    mong_cn = Mongo::Connection.new(MONGO_OPTION[:host],MONGO_OPTION[:port])
    mong_db = mong_cn.db(MONGO_OPTION[:database_name])

    puts "----------------province--------------------"
    sql_select_province = sql.query("select * from province")
    china = City.create(:name => 'China')
    City.roots << china
      while row_province = sql_select_province.fetch_hash
        obj_province = china.children.create(name: row_province["province"])

        sql_select_city = sql.query("select * from city where fatherid = #{row_province["provinceid"]}")
        while row_city = sql_select_city.fetch_hash
          obj_city = obj_province.children.create(name: row_city["city"])

          sql_select_area = sql.query("select * from area where fatherid = #{row_city["cityid"]}")
          while row_area = sql_select_area.fetch_hash
            obj_city.children.create(name: row_area["area"])
          end
        end
      end

    puts ("--------------------end-------------------------")
  end

  YCity = Struct.new :id, :name, :parent

  def generate_city(parent, node, id, results = [])
    children = node.children
    children.each do |node|
      id = id.succ
      city = YCity.new(id, node.name, parent.id)
      results << city
      id = generate_city(city, node, id, results)
    end
    id
  end

  require 'yaml/store'
  output_path = "#{Rails.root}/config"
  file_name = "city.yml"

  task :mongo_to_yml => :environment do


    Mongodb::City.store_in(collection: :cities)
    # change database table prefix :mongodb
    id = "0000000"


    store = YAML::Store.new File.join(output_path, file_name)

    store.transaction do
      Mongodb::City.roots.each do |root|
        results = []
        results << first = YCity.new(id, root.name, nil)
        generate_city(first, root, id, results )
        store[root.name] = results
      end
    end
  end

  def load_city_node(ycity, parent, collection)
    collection.select { |c| c.parent == ycity.id }.each do |ynode|
      city_node = parent.children.create(name: ynode.name, ancestry: parent)
      load_city_node(ynode, city_node, collection)
    end
  end

  task :load => :environment do
    City.destroy_all

    config = YAML.load_file(File.join(output_path, file_name))
    config.each do |k,cities|
      country = cities.shift
      root = City.create(name: country.name)
      load_city_node(country, root, cities)
    end
  end
end