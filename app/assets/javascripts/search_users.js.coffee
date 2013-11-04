root = window || @

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
      #@$(".wrapper > div").animate({
      #  left: '20px'},'slow', () => @$(".wrapper > div").fadeOut());
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
      type: "get",
      url: "/search/circles.dialog",
      data: {q: @$(".circle_input_info").val() ,area_id: @options.area_id }
      success: (data) =>
        if data == ""
          $(@notice).insertBefore(@$(".wrapper"))
        else
          @$(".wrapper").html(data)
    })


root.FindUserView = FindUserView
root.FindCircleView = FindCircleView
