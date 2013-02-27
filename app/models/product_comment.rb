#encoding: utf-8

#describe: 产品评论模型
class ProductComment < ActiveRecord::Base
  attr_accessible :content, :product_id, :user_id

  belongs_to :product
  belongs_to :user

end
