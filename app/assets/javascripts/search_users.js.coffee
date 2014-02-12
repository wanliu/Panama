#= require 'lib/card_info'

root = window || @

class NewUsersView extends Backbone.View
  events:
    "click .hot_region_search" : "hot_region_search"

  initialize: () ->
    _.extend(@, @options)
    @get_hot_regions()
    @buyer_template = Handlebars.compile($("#buyer_base_template").html())
    @seller_template = Handlebars.compile($("#seller_base_template").html())
    @hot_region_template = Handlebars.compile("<a id='{{ id }}' href='#' class='hot_region_search'>{{ name }}</a>&nbsp;")
    @$wrapper = @$(".wrapper")

  get_hot_regions: () ->
    $.ajax({
      dataType: "json",
      type: "get",
      url: "/communities/hot_region_name",
      success: (datas) =>
        _.each datas, (data) =>
          @$(".hot_region span").append(@hot_region_template(data))
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
    if datas.length == 0
      @$(".find_people_tip").show()
    else
      @$(".wrapper > div").animate({left: '20px'},'slow',@$(".wrapper > div").fadeOut());
      _.each datas, (data) =>
        view = if _.contains(data.service.split(","),"buyer")      
          new UserCardInfo(
            el: $(@buyer_template(_.extend(data, data.user))),
            model: data
          )
        else
          new ShopCardInfo(
            el: $(@seller_template(_.extend(data, data.shop))),
            model: data
          )          

        @appendToWrapper(view.render());

  appendToWrapper: (el) ->

    if @$(".wrapper").find(".span4").length % 3 == 0
      @$row = $("<div class='row-fluid' />").appendTo(@$wrapper)

    @$row.append(el)


class FindUserView extends Backbone.View
  events: 
    "click .find_people"              : "find_user"
    "keypress input.people_input_info": "key_up"

  initialize: () ->
    _.extend(@, @options)
    @buyer_template = Handlebars.compile($("#buyer_base_template").html())
    @seller_template = Handlebars.compile($("#seller_base_template").html())

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

  render: (datas) =>
    if datas.length == 0
      @$(".find_people_tip").show()
    else
      @$(".alert").fadeOut()
      @$(".wrapper").html ""
      _.each datas, (data) =>
        view = if _.contains(data.service.split(","), "buyer")          
          new UserCardInfo(
            el: $(@buyer_template(_.extend(data, data.user))),
            model: data
          )
        else
          new ShopCardInfo(
            el: $(@seller_template(_.extend(data, data.shop))),
            model: data
          )

        @appendToWrapper(view.render());
 
  appendToWrapper: (el) ->

    if @$(".wrapper").find(".span4").length % 3 == 0
      @$row = $("<div class='row-fluid' />").appendTo(@$(".wrapper"))

    @$row.append(el)



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
