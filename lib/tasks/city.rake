#encoding: utf-8
 

desc 'city  mysql to mongo'
task :city => :environment do    
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