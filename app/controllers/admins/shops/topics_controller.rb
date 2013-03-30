#encoding: utf-8
class Admins::Shops::TopicsController < Admins::Shops::SectionController

  def create
    opts = max_level(params[:friends])
    if opts[:status] == :circle && opts[:circles].length <=0
      respond_format({message: "没有选择范围!"}, 403)
      return
    end
    @topic = current_shop.topics.create(
      status: opts[:status],
      content: params[:content],
      user_id: current_user.id)
    if @topic.valid?
      opts[:circles].each do |circle|
        @topic.receives.create(receive: circle)
      end
      respond_format(format_json(@topic))
    else
      respond_format(draw_errors_message(@topic), 403)
    end
  end

  def index
    _topics = params[:circles]=="related" ? receive_topic : circle_topics
    @topics = _topics.limit(30).order("created_at desc")
    respond_to do |format|
      format.json{ render json: @topics }
      format.html
    end
  end

  def my_related
    @circles = current_shop.circles

    respond_to do |format|
      format.html
      format.json{ render json: @topics }
    end
  end

  private
  def receive_topic
    current_shop.topic_receives.joins(:topic)
  end

  def circle_topics
    @circles = current_shop.circles
    unless params[:circle_id].blank?
      @circles = @circles.where(:id => params[:circle_id])
    end
    current_shop.all_circle_topics(@circles)
  end

  def respond_format(json, status = 200)
    respond_to do |format|
      format.json{ render json: json, status: status }
    end
  end

  def const_get(name)
    Kernel.const_get(name)
  end

  def receive_other(friends)
    receives = []
    friends.each do |f|
      receive = const_get(f[:status].classify).find_by(id: f[:id])
      receives << receive unless receive.nil?
    end
    {status: :circle, circles: receives}
  end

  def max_level(friends)
    if is_level(friends, "puliceity")
      return {status: :puliceity}
    elsif is_level(friends, "external")
      circles = current_shop.circles + current_shop.all_friend_circles
      return {status: :external, circles: circles}
    elsif is_level(friends, "circle")
      return {status: :circle, circles: current_shop.circles}
    else
      return receive_other(friends)
    end
  end

  def is_level(friends, id)
    _status = false
    friends.each do |f|
      friend = f.symbolize_keys
      if friend[:id] == id && friend[:status] == "scope"
        _status = true
        break
      end
    end
    _status
  end
end