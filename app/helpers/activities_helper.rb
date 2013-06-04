module ActivitiesHelper

  def render_activity(activity)
    case activity.activity_type
    when "auction" # 竞价
      render "activities/auction/preview", activity: activity
    when "score"   # 积分
      render "activities/score/preview", activity: activity
    when "package" # 捆绑
      render "activities/package/preview", activity: activity
    when "focus"   # 聚焦
      render "activities/focus/preview", activity: activity
    when "courage" # 吞货
      render "activities/courage/preview", activity: activity
    else
      render "preview", activity: activity
    end
  end
end
