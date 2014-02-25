#= require 'lib/card_info'

root = window || @

class RenderMethod  

  constructor: (options) ->
    _.extend(@, options)
    @$wrapper = @el.find(".wrapper")
    @buyer_template = Handlebars.compile($("#buyer_base_template").html())
    @seller_template = Handlebars.compile($("#seller_base_template").html())
    # @render(@datas)

  render: (datas) ->
    if datas.length == 0
      @el.find(".find_people_tip").show()
    else
      # @el.find(".wrapper > div").animate({left: '20px'},'slow',@el.find(".wrapper > div").fadeOut());
      @el.find(".find_people_tip").hide()
      @el.find(".wrapper > div").remove()
      _.each datas, (data) =>
        view = ""
        if _.contains(data.service.split(","),"buyer")    
          view = new UserCardInfo(
            el: $(@buyer_template(_.extend(data, data.user))),
            model: data
          )
          new FollowView({
            data: {
              follow_id:  data.user.id,
              follow_type: "User"
            },
            login: @current_user_login,
            el: view.$el
          })
        else
          view = new ShopCardInfo(
            el: $(@seller_template(_.extend(data, data.shop))),
            model: data
          )
          new FollowView({
            data: {
              follow_id:  data.shop.id,
              follow_type: "Shop"
            },
            login: @current_user_login,
            el: view.$el
          })

        @appendToWrapper(view.render());

  appendToWrapper: (el) ->
    if @$wrapper.find(".span4").length % 3 == 0
      @$row = $("<div class='row-fluid' />").appendTo(@$wrapper)
    @$row.append(el)


class NewUsersView extends Backbone.View
  events:
    "click .hot_region_search" : "hot_region_search"

  initialize: () ->
    _.extend(@, @options)
    @get_hot_regions()
    @hot_region_template = Handlebars.compile("<a id='{{ id }}' href='#' class='hot_region_search'>{{ name }}</a>&nbsp;")
    @$wrapper = @$(".wrapper")

  get_hot_regions: () ->
    $.ajax({
      dataType: "json",
      type: "get",
      url: "/communities/hot_region_name",
      success: (datas) =>
        if datas.length > 0
          _.each datas, (data) =>
            @$(".hot_region span").append(@hot_region_template(data))
        else
          @$(".hot_region span").append("暂无热区")
    })

  hot_region_search: (event) ->
    @$(".find_people_tip").hide()
    id = event.currentTarget.id
    $.ajax({
      type: "get",
      dataType: "json",
      data:{region_id: id },
      url: "/communities/search",
      success: (datas) =>
        @render(datas)
    })
    return false

  render: (datas) =>
    new RenderMethod(el: @$el,current_user_login: @current_user_login).render(datas)


class FindUserView extends Backbone.View
  events: 
    "click .find_people"              : "find_user"
    "keypress input.people_input_info": "key_up"

  initialize: () ->
    _.extend(@, @options)

  key_up: (e) =>
    @find_user() if e.keyCode == 13

  find_user: () ->
    @$(".find_people_tip")
    keyword = @$(".people_input_info").val().trim()
    $.ajax({
      type: "get",
      dataType: "json",
      url: "/search/user_checkings",
      data: {q: keyword ,area_id: @options.area_id }
      success: (datas) =>
        @render(datas)
    })

  render: (datas) ->
    new RenderMethod(el: @$el,current_user_login: @current_user_login).render(datas)

class FindCircleView extends Backbone.View
  events: 
    "click .find_circle"               : "find_circle"
    "keypress input.circle_input_info" : "key_up"

  initialize: () ->
    _.extend(@, @options)

  key_up: (e) =>
    @find_circle() if e.keyCode == 13

  find_circle: () ->
    @$(".find_circle_tip").hide()
    keyword = @$(".circle_input_info").val().trim()
    $.ajax({
      type: "get",
      url: "/search/shop_circles",
      data: {q: keyword ,area_id: @options.area_id }
      success: (data) =>
        if data == ""
          @$(".find_circle_tip").show()
        else
          @$(".alert").fadeOut()
          @$(".wrapper").html(data)
    })


root.NewUsersView = NewUsersView
root.FindUserView = FindUserView
root.FindCircleView = FindCircleView
