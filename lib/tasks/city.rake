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
    while row_province = sql_select_province.fetch_hash
        if mong_db["city"].find(:provinceid => row_province["provinceid"]).to_a.length < 1
	        ro = [:name => row_province["province"],:city_id => nil,:provinceid => row_province["provinceid"]]
	        mong_db["city"].insert(ro)
	    end
    end

    puts "----------------city--------------------" 
   	sql_select_city = sql.query("select * from city")
    while row_city = sql_select_city.fetch_hash
        if mong_db["city"].find(:provinceid => row_city["cityid"]).to_a.length < 1
        	father_id = mong_db["city"].find(:provinceid => row_city["fatherid"]).to_a[0]["_id"] 
	        ro = [:name => row_city["city"],:city_id => father_id,:provinceid => row_city["cityid"]]
	        mong_db["city"].insert(ro)
	    end
    end

    puts "----------------area--------------------" 
    sql_select_area = sql.query("select * from area")
    while row_area = sql_select_area.fetch_hash
        if mong_db["city"].find(:provinceid => row_area["areaid"]).to_a.length < 1
        	father_id = mong_db["city"].find(:provinceid => row_area["fatherid"]).to_a[0]["_id"] 
	        ro = [:name => row_area["city"],:city_id => father_id,:provinceid => row_area["areaid"]]
	        mong_db["city"].insert(ro)
	    end
    end

	puts ("--------------------end-------------------------")
end