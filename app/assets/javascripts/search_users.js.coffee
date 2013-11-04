root = window || @

class NewUsersView extends Backbone.View

  events:
    "click .hot_region_search" : "hot_region_search"

  initialize: () ->
    _.extend(@, @options)
    @get_hot_regions()
    @buyer_template = Hogan.compile($("#buyer_base_template").html())
    @seller_template = Hogan.compile($("#seller_base_template").html())
    @hot_region_template = Hogan.compile("<a id='{{ id }}' href='#' class='hot_region_search'>{{ name }}</a>&nbsp;")
    @notice = $("<div class='alert'>
            <button type='button' class='close' data-dismiss='alert'>&times;</button>
            <span>您搜索的区域暂时没有成员～～～～</span>
          </div>")

  get_hot_regions: () ->
    $.ajax({
      dataType: "json",
      type: "get",
      url: "/communities/hot_region_name",
      success: (datas) =>
        _.each datas, (data) =>
          @$(".hot_region span").append(@hot_region_template.render(data))
    })

  hot_region_search: (event) ->
    id = event.currentTarget.id
    $.ajax({
      dataType: "json",
      type: "get",
      data:{region_id: id } ,
      url: "/communities/search",
      success: (datas) =>
        @render(datas)
    })
    return false

  render: (datas) =>
    if datas.length == 0
      $(@notice).insertBefore(@$(".wrapper"))
    else
      @$(".alert").fadeOut()
      @$(".wrapper > div").animate({left: '20px'},'slow',@$(".wrapper > div").fadeOut());
      _.each datas, (data) =>
        tpl = if data.service_id == 1
          @buyer_template
        else
          @seller_template
        @$(".wrapper").append(tpl.render(data))

class FindUserView extends Backbone.View
  events: 
    "click .find_people"              : "find_user"
    "keypress input.people_input_info": "key_up"

  notice:
    "<div class='alert'>
      <button type='button' class='close' data-dismiss='alert'>&times;</button>
      <span>没有找到符合要求的用户或商店</span>
    </div>"

  initialize: () ->
    _.extend(@, @options)
    @buyer_template = Hogan.compile($("#buyer_base_template").html())
    @seller_template = Hogan.compile($("#seller_base_template").html())

  key_up: (e) =>
    @find_user() if e.keyCode == 13

  find_user: () ->
    $.ajax({
      type: "get",
      dataType: "json",
      url: "/search/user_checkings",
      data: {q: @$(".people_input_info").val() ,area_id: @options.area_id }
      success: (datas) =>
        @render(datas)
    })

  render: (datas) =>
    if datas.length == 0
      $(@notice).insertBefore(@$(".wrapper"))
    else
      @$(".alert").fadeOut()
      @$(".wrapper").html ""
      _.each datas, (data) =>
        tpl = if data.service_id == 1
          @buyer_template
        else
          @seller_template
        @$(".wrapper").append(tpl.render(data))


class FindCircleView extends Backbone.View
  events: 
    "click .find_circle" : "find_circle"
    "keypress input.circle_input_info": "key_up"

  notice:
    "<div class='alert'>
      <button type='button' class='close' data-dismiss='alert'>&times;</button>
      <span>没有找到符合要求的本地商圈</span>
    </div>"

  initialize: () ->
    _.extend(@, @options)

  key_up: (e) =>
    @find_circle() if e.keyCode == 13

  find_circle: () ->
    $.ajax({
      url: "/search/shop_circles.dialog",
      type: "get",
      url: "/search/circles.dialog",
      data: {q: @$(".circle_input_info").val() ,area_id: @options.area_id }
      success: (data) =>
        if data == ""
          $(@notice).insertBefore(@$(".wrapper"))
        else
          @$(".wrapper").html(data)
    })

root.NewUsersView = NewUsersView
root.FindUserView = FindUserView
root.FindCircleView = FindCircleView
