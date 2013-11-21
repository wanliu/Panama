# encoding: utf-8
# require "redis"
namespace :redis_user do
  desc "load user information to redis"
  task :load => :environment do
    redis_client = RedisClient.redis
    redis_client.del("Panama:userId:userName")# if redis_client.exists("Panama:userId:userName")
    redis_client.del("Panama:userName:userId")# if redis_client.exists("Panama:userName:userId")
    result = []
    User.all.each do |user|
      user_name = user.login
      user_id   = user.id

      result.push redis_client.hset("Panama:userId:userName", user_id, user_name)
      result.push redis_client.hset("Panama:userName:userId", user_name, user_id)
    end

    if result.any? {|item| item == 0}
      puts "错误：含有相同登陆名的用户，请检查后重新导入！！"
    end
  end
end