module ActivitiesHelper

  def render_activity(activity)
    case activity.activity_type
    when "auction" # 竞价
      render "auction/activity", activity: activity
    when "score"   # 积分
      render "score/activity", activity: activity
    when "package" # 捆绑
      render "package/activity", activity: activity
    when "focus"   # 聚焦
      render "focus/activity", activity: activity
    when "courage" # 吞货
      render "courage/activity", activity: activity
    else
      render "activity", activity: activity
    end
  end
end
