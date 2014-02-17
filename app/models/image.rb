class Image < ActiveRecord::Base
  attr_accessible :filename
  belongs_to :imageable, :polymorphic => true

  attr_accessor :uploader_secure_token
  mount_uploader :filename, AvatarUploader

  after_update do
    if imageable.is_a?(User)
      imageable.update_attributes(:updated_at => DateTime.now)
      imageable.update_relation_index
    end
  end

  after_save :update_channel_icon
  
  def default_url
    "http://panama-img.b0.upaiyun.com/product_blank.gif"
  end

  def url(version_name = "")
    @url= filename || default_url
    version_name = version_name.to_s
    return @url if version_name.blank?
    [@url,version_name].join("!") # 我这里在图片空间里面选用 ! 作为“间隔标志符”
  end

  def update_channel_icon
    if imageable.is_a?(User)
      PersistentChannel.update_all("icon = '#{url("50x50")}'",[ "name = ?", imageable.login ])
    end
  end
end
