#encoding: utf-8
class Admins::Shops::TopicsController < Admins::Shops::SectionController

  def create
    opts = max_level(params[:topic].delete(:friends))
    params[:topic].delete(:topic_category_id) unless opts[:status] == :community
    if opts[:circles].length <= 0
      respond_format({message: "没有选择范围!"}, 403)
      return
    end
    @topic = current_shop.topics.create(params[:topic].merge({
        status: opts[:status],
        user_id: current_user.id
      }))
    if @topic.valid?
      opts[:circles].each do |circle|
        @topic.receives.create(receive: circle)
      end
      respond_format(@topic.as_json(:include => :owner))
    else
      respond_format(draw_errors_message(@topic), 403)
    end
  end

  def index
    _topics = params[:circle_id]=="community" ? receive_topic : circle_topics
    @topics = _topics.limit(30).order("created_at desc")
    respond_to do |format|
      format.json{ render json: @topics.as_json(:include => :owner) }
      format.html
    end
  end

  def my_related
    @circles = current_shop.circles
    @followers = current_shop.followers
    @categories = current_shop.topic_categories
    respond_to do |format|
      format.html
      format.json{ render json: @topics }
    end
  end

  def category
    @topics = current_shop.topics.where(topic_category_id: params[:topic_category_id])
    respond_to do |format|
      format.json{ render json: @topics }
      format.html
    end
  end

  def receives
    @topic = current_shop.topics.find(params[:id])
    respond_to do |format|
      format.json{ render json: @topic.receive_users }
      format.html
    end
  end

  private
  def receive_topic
    Topic.where(:id => current_shop.topic_receives.map{|t| t.topic_id})
  end

  def circle_topics
    if params[:circle_id] == "all"
      @circles = :all
    elsif not params[:circle_id].blank?
      @circles = current_shop.circles.where(:id => params[:circle_id])
    end
    current_shop.all_circle_topics(@circles)
  end

  def respond_format(json, status = 200)
    respond_to do |format|
      format.json{ render json: json, status: status }
    end
  end

  def max_level(friends)
    if Topic.is_level(friends, "puliceity")
      return {status: :community, circles: [current_shop]}
    elsif Topic.is_level(friends, "external")
      circles = current_shop.circles + current_shop.all_friend_circles
      return {status: :external, circles: circles}
    elsif Topic.is_level(friends, "circle")
      recievs = Topic.receive_other(friends)
      recievs[:circles] = current_shop.circles + recievs[:circles]
      return recievs
    else
      return Topic.receive_other(friends)
    end
  end

end