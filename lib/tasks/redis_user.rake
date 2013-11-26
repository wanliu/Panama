# encoding: utf-8
# require "redis"
namespace :redis_user do
  desc "load user information to redis"
  task :load => :environment do
    user_id_to_user_name = RedisClient.redis_keys["user_id_to_user_name"]
    user_name_to_user_id = RedisClient.redis_keys["user_name_to_user_id"]

    userId_userName = []
    userName_userId = []
    User.all.each do |user|
      user_name = user.login
      user_id   = user.id

      userId_userName.push(user_id, user_name)
      userName_userId.push(user_name, user_id)
    end

    redis_client = RedisClient.redis
    result = redis_client.multi do
      redis_client.del(user_id_to_user_name)# if redis_client.exists("Panama:userId:userName")
      redis_client.del(user_name_to_user_id)# if redis_client.exists("Panama:userName:userId")
      redis_client.hmset(user_id_to_user_name, *userId_userName)
      redis_client.hmset(user_name_to_user_id, *userName_userId)
    end

    if [1, 1, "OK", "OK"] == result || [0, 0, "OK", "OK"] == result
      puts "congratulations!! import successed"
    else
      puts "result : #{result}"
      puts "I am sorry, importing fails, pleace check an try again"
    end
  end
end