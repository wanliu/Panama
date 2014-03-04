#encoding: utf-8
class People::CommunitiesController < People::BaseController
  before_filter :login_required
  before_filter :person_self_required, :only => [:create]

  layout "people"
  
  def index
  end

  def show
    @circle = Circle.find_by(:id => params[:id])
    respond_to do |format|
      format.html{ render :layout => "circles" }
    end
  end

  def all_circles
    @circles = @people.all_circles
    respond_to do |format|
      format.html{ render :layout => false }
      format.dialog{ render :layout => false }
    end
  end

  def all_topics
    circle_ids = CircleFriends.where(:user_id => @people.id).pluck(:circle_id)
    @topics = Topic.joins("left join circles as c on topics.circle_id = c.id").where("c.id in (?)",circle_ids).order("updated_at desc").offset(params[:offset]).limit(params[:limit])
    respond_to do |format|
      format.json{ render :json => @topics.as_json(
        :methods => [:comments_count, :top_comments]) }
    end
  end

  def create
  	@setting = CircleSetting.create(params[:setting])
    params[:circle].merge!(:setting_id => @setting.id)
  	@circle = @people.circles.create(params[:circle])
    CircleCategory.create(:name => "分享", :circle_id => @circle.id)

  	respond_to do |format|
  		format.html { redirect_to person_circles_path(@people) }
      format.json { head :no_content }
  	end
  end


end