module ActivitiesHelper

  def render_activity(activity)
    if activity.is_a?(Activity)
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
        if activity.is_a?(Product)

        else
          render "activities/products/preview", activity: activity
        end
      end
    else
      case activity.class.name
      when "AskBuy"
        render "ask_buy/preview", ask_buy: activity
      else
      end
    end
  end
end
