root = window || @

class SearchUserView extends Backbone.View

  events:
    "click .search_user" : "form_query_user"
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
        new YellowInfoPreviewList({el : @el })
    })
    return false

  form_query_user: () ->
    values = @$("form.address_from_post").serializeArray()
    data = {}
    _.each values, (v) -> data[v.name] = v.value

    $.ajax({
      type: "get",
      dataType: "json",
      data:  data,
      url: "/communities/search"
      success: (datas) =>
        @render(datas)
        new YellowInfoPreviewList({el : @el })
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

  initialize: () ->
    _.extend(@, @options)
    @buyer_template = Hogan.compile($("#buyer_base_template").html())
    @seller_template = Hogan.compile($("#seller_base_template").html())
    @notice = $("<div class='alert'>
            <button type='button' class='close' data-dismiss='alert'>&times;</button>
            <span>没有找到符合要求的用户或商店</span>
          </div>")

  events: 
    "click .find_people" : "find_user"

  find_user: () ->
    $.ajax({
      dataType: "json",
      url: "/search/user_checkings",
      type: "get",
      data: {q: @$(".input_info").val() ,area_id: @options.area_id }
      success: (datas) =>
        @render(datas)
        new YellowInfoPreviewList({el : @el })
    })

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


root.FindUserView = FindUserView
root.SearchUserView = SearchUserView
