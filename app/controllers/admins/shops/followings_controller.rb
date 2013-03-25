#encoding: utf-8
#商店关注
class Admins::Shops::FollowingsController < Admins::Shops::SectionController

  def index
    @followings = current_shop.followers
    respond_to do |format|
      format.html
      format.json{ render :json => @followings }
    end
  end

end