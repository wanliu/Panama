#describe: 搜索用户

root = window || @

class UserList extends Backbone.Collection
  url: "/search/users"

class root.SearchUserView extends Backbone.View
  className: "search_users circle_friend"

  initialize: (options) ->
    _.extend(@, options)
    @users = new UserList()
    @users.bind("reset", @all, @)
    @users.bind("add", @add, @)
    @input = @input_el.find("input:text")
    @$el = $(@el)

    @input_el.on "keyup", "input:text", () =>
      clearTimeout(@time_id) if @time_id?
      @time_id = setTimeout(_.bind(@search_user, @), 300)

    @input_el.on "focus", "input:text", () =>
      @show() if @input.val().trim() isnt ""

  search_user: () ->
    query = @input.val().trim()
    return if query is @query_val
    if query == ""
      @hide_to_switch()
    else
      @query_val = query
      @$el.html("正在加载中...")
      @users.fetch(data: {q: query})

  all: (collection) ->
    @show()
    @$el.html("")
    collection.each (model) =>
      @add(model)

    if collection.length<=0
      @$el.html("未找到匹配的人...")
    else
      @bind_drop()

  add: (model) ->
    @$el.append("
      <div class='panel-pj user' data-value-id='#{model.id}'>
        <div>
          <img src='#{model.get("icon_url")}' class='img-polaroid' />
        </div>
        <div>
          <label class='label login'>#{model.get("login")}</label>
        </div>
      </div>
    ")

  hide_to_switch: () ->
    @hide()
    @trigger("switch_show")

  hide: () ->
    @$el.hide()

  show: () ->
    @trigger("hide_all")
    @$el.show()

  render: () ->
    @$el

  bind_drop: () ->
    @$el.find(".user").draggable({
      helper: 'clone',
      opacity: 0.7,
      revert: true,
      revertDuration: 200,
      zIndex: 1
    })

SearchUserView