class Mongodb::Image
  include Mongoid::Document
  field :filename, type: String

  belongs_to :imageable, :polymorphic => true

  def default_url
    "http://panama-img.b0.upaiyun.com/product_blank.gif"
  end

  def url(version_name = "")
    @url= filename || default_url
    version_name = version_name.to_s
    return @url if version_name.blank?
    [@url,version_name].join("!") # 我这里在图片空间里面选用 ! 作为“间隔标志符”
  end  
end
