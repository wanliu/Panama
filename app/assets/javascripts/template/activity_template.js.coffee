root = (window || @)

class root.ActivityViewTemplate extends Backbone.View
  initialize: () ->
    @template = Hogan.compile($("##{@model.activity_type}-preview-template").html())
    @$el = $(@template.render(@model)) if @template

  render: () ->
    @show_status(@get_status())
    @

  show_status: (status) ->
    @$el.find(".price").html(@model.price.toString().toMoney()) if @model.price
    @$el.find(".time-left").html(status.text).addClass(status.name)
    switch status.name
      when 'over'
        $(".buttons>.launch-button", @$el).remove()
      when 'waiting'
        $(".buttons>.launch-button", @$el).remove()

  get_status: () ->
    ###
    time_wait = @model.start_time.toDate().getTime() - new Date().getTime()
    return {name: 'waiting', text: "敬请期待"} unless time_wait < 0 && @model.status == 1
    time_left = @model.end_time.toDate().getTime() - new Date().getTime()
    return {name: 'over', text: "已结束"} unless time_left > 0

    leave1 = time_left%(24*3600*1000) # 计算天数后剩余的毫秒数
    leave2 = leave1%(3600*1000)
    # leave3 = leave2%(60*1000)
    days = Math.floor(time_left/(24*3600*1000))
    return {name: 'started', text: "还剩#{days}天"} if days > 0
    hours = Math.floor(leave1/(3600*1000))
    return {name: 'started', text: "仅剩#{hours}小时"} if hours > 0
    minutes = Math.floor(leave2/(60*1000))
    return {name: 'started', text: "最后#{minutes}分钟"} if minutes > 0
    # seconds = Math.round(leave3/1000)
    ###
    info = @model.setup_time
    result = {name: info.state}
    if info.state == "started"      
      result.text = switch info.time_type
        when "day" then "还剩#{info.time}天"
        when "hour" then "仅剩#{info.time}小时"
        when "minute" then "最后#{info.minute}分钟"
        when "second" then "最后#{info.second}秒"
        else ""
    else if info.state == "waiting"
      result.text = "敬请期待"
    else if info.state == "over"
      result.text = "已结束"

    result
