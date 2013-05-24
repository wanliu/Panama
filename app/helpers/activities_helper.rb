module ActivitiesHelper

  def render_activity(activity)
    case activity.activity_type
    when "auction" # 竞价
      render "activities/auction/activity", activity: activity
    when "score"   # 积分
      render "activities/score/activity", activity: activity
    when "package" # 捆绑
      render "activities/package/activity", activity: activity
    when "focus"   # 聚焦
      render "activities/focus/activity", activity: activity
    when "courage" # 吞货
      render "activities/courage/activity", activity: activity
    else
      render "activity", activity: activity
    end
  end
end
