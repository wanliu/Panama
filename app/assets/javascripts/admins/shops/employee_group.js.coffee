#author: huxinghai
#邀请雇员与雇加入组别
#= require jquery
#= require jquery-ui
#= require backbone
#= require twitter/bootstrap/tab
#= require twitter/bootstrap/modal
#= require lib/hogan

exports = window || @

#组权限模型
class Group extends Backbone.Model
  set_url: (shop) ->
    @url = "/shops/#{shop}/admins/groups"

  constructor: (attrs, shop) ->
    @set_url(shop)
    super attrs

  permissions: (callback) ->
    @fetch({
      url: "#{@url}/permissions/#{@get('id')}",
      success: callback
    })

  check_permissions: (data) ->
    @fetch({
      url: "#{@url}/check_permissions/#{@get('id')}",
      type: "POST"
      data: {permissions: data}
    })

  create: (data, callback) ->
    @fetch({
      url: "#{@url}",
      data: data,
      type: "POST",
      success: callback
    })
  destroy: (callback) ->
    @fetch({
      url: "#{@url}/#{@get('id')}",
      type: "DELETE",
      success: callback
    })

#组列表集合
class GrupList extends Backbone.Collection
  model: Group
  set_url: (shop) ->
    @url = "/shops/#{shop}/admins/groups"

  constructor: (attrs, shop) ->
    @set_url(shop)
    super attrs

#雇员模型
class Employee extends Backbone.Model
  set_url: (shop) ->
    @url = "/shops/#{shop}/admins/employees"
  constructor: (attrs, shop) ->
    @set_url(shop)
    super attrs

  destroy:(callback) ->
    this.fetch(
      url: "#{@url}/destroy/#{ @get('id')}",
      type: "delete"
      # data: {user_id: @get("id")},
      success: callback
    )

  employee_join_group: (data, callback, error_callback) ->
    this.fetch({
      url: "#{@url}/group_join_employee",
      data: data,
      type: "POST",
      success: callback,
      error: error_callback
    })

  group_remove_employee: (data, callback) ->
    this.fetch({
      url: "#{@url}/group_remove_employee",
      data: data,
      type: "DELETE",
      success: callback
    })

  invite: (login, callback, error_callback) ->
    if _.isEmpty(login)
      pnotify(text: "请填写邀请人的Email或者用户名", type: "warning")
      return false  
    this.fetch({
      url: "#{@url}/invite",
      data: {login: login},
      type: 'post',
      success: callback,
      dataType: 'JSON',
      error: error_callback
    })

#雇员集合
class EmployeeList extends Backbone.Collection
  model: Employee

  constructor: (models, shop) ->
    @url = "/shops/#{shop}/admins/employees"
    super models

  find_group_user: (data) ->
    this.fetch(
      url: "#{@url}/find_by_group",
      data: data
    )

#组的雇员视图
class GroupEmployeeView extends Backbone.View
  events: {
    "click .remove-shop-user-group" : "remove"
  }
  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @$el.html(@template.render(@model.toJSON()))
    $("img.avatar", @$el).attr("src", @model.get('icon_url'))
    @model.bind("remove_employee_el", _.bind(@remove_el, @))

  render: () ->
    @$el

  remove: () ->
    if confirm("是否确认删除#{@model.get('login')}用户权限?")
      @model.group_remove_employee({
          shop_user_id: @model.id,
          shop_group_id: @group_id
        }, (data, xhr) => @remove_el()
      )
  remove_el: () ->
    @el.remove()
    @trigger("remove_employee", @model.id)

#组的雇员视图列表
class GroupEmployeeListView extends Backbone.View
  className: "tab-pane fade"
  notice_template: $("<div class='alert alert-warning notice'>暂无雇员</div>")
  initialize: (options) ->
    _.extend(@, options)

    @$el = $(@el)
    @$el.attr("id", "group-#{@group.get('id')}")
    @bind_droppable()

    @employee_list = new EmployeeList([], @shop)
    @employee_list.bind("reset", @all_employee, @)
    @employee_list.bind("add", @add_employee, @)
    @employee = new Employee({}, @shop)
    @group.bind("group_remove_employee", _.bind(@group_remove_employee, @))
    @group.bind("destroy", @remove, @)
    @load_employee()

  bind_droppable: () ->
    @$el.droppable({
      drop: $.proxy(@drop, @)
    })

  drop: (event, ui) ->
    employee_id = ui.helper.attr("data-value-id")
    @employee.employee_join_group({shop_user_id: employee_id, shop_group_id: @group.id},
    (model, data) =>
        @$el.find(".notice").remove()
        @employee_list.add(data)
    (model, data) =>
        alert(JSON.parse(data.responseText).message)
    )

  render: () ->
    @$el

  load_employee: () ->
    @$el.html('正在加载...')
    @employee_list.find_group_user({group_id: @group.id})
  all_employee: (collection) ->
    @$el.html('')
    collection.each((model) =>
        @add_employee(model)
    )
    @inspect_employee()

  add_employee: (model) ->
    model.set_url(@shop)
    employee_view = new GroupEmployeeView({
        model: model,
        template: @employee_template,
        group_id: @group.id
    })
    employee_view.bind("remove_employee", _.bind(@remove_employee, @))
    @$el.append(employee_view.render())

  group_remove_employee: (user_id) ->
    model = @find_employee_id(user_id)
    if model?
        @remove_employee(model)
        model.trigger("remove_employee_el")

  remove_employee: (model) ->
    @employee_list.remove(model)
    @inspect_employee();

  #检查如果没有雇员就显示提示信息
  inspect_employee: () ->
    if(@employee_list.length<=0)
        @$el.html(@notice_template.clone())

  find_employee_id: (user_id) ->
    for user in  @employee_list.models
        if user.get("id") is user_id
            return user

    null
  remove: () ->
    @$el.remove()

  render_group: () ->
    li = $("<li data-value-id=#{@group.id} />")
    # li.html("<span class='close-group icon-remove'></span>")
    li.append($("<a href='#group-#{@group.id}' data-toggle='tab'>#{@group.get('name')}</a>"))
    li

#组视图列表
class GroupViewList extends Backbone.View
  events: {
    "click .close-group" : "remove_group"
    },

  initialize: (options) ->
    _.extend(@, options)
    @groups = new GrupList({}, @shop)
    @$group_header = @$('ul.user-group-header')
    @$group_content = @$('.user-group-content')
    @groups.bind("add", @add_group, @)
    @groups.bind("reset", @all_group, @)
    @groups.fetch()


  all_group: (collection) ->
    collection.each (model) =>
        @add_group(model)

    @show_first()

  add_group: (model) ->
    model.set_url(@shop)
    #组的雇员视图
    group_employee_view = new GroupEmployeeListView({
        group: model,
        employee_template: @group_user_template,
        shop: @shop
    })
    @$group_header.append(group_employee_view.render_group())
    @$group_content.append(group_employee_view.render())

  remove_group_user: (user_id) ->
    @groups.each (model) =>
        model.trigger("group_remove_employee", user_id)

  remove_group: (event) ->
    li = $(event.currentTarget.parentElement)
    id = li.attr("data-value-id")
    model = @groups.get(id)
    if confirm("是否确认删除#{model.get('name')}组吗?")
        model.destroy (data) =>
            li.remove()
            model.trigger("destroy")
            @show_first()
            @groups.remove(model)

  show_first: () ->
    $("li>a:first", @$group_header).click()

#雇员视图
class EmployeeView extends Backbone.View
  events: {
    "click .remove" : "remove"
  }
  initialize: (options) ->
    _.extend(@, options)
    @model = new Employee({
        id: parseInt(@el.attr("data-value-id"))
        login: @el.attr("data-value-login")
    }, @shop)
    @bind_drag_employee()


  bind_drag_employee: () ->
    @el.draggable({
      helper: 'clone',
      opacity: 0.7,
      revert: true,
      revertDuration: 200,
      zIndex: 1
    })

  remove: () ->
    if confirm("是否确认解雇#{@model.get('login')}用户？")
        @model.destroy (data) =>
            @el.remove()
            @trigger("remove_group_employee", @model.id)
            @trigger("inspect_employee")

#组权限视图
class PermissionGroupView extends Backbone.View
    className: "tab-pane permission-group"

    events: {
      "click .resource" : "check_resource"
      "click .abilities input:checkbox" : "check_permission"
    }

    initialize: (opts) ->
      _.extend(@, opts)
      @$el = $(@el)
      @$el.attr("id", "permission-group-#{@model.id}")
      @$el.html(@template.render())
      @$resource_panels = @$(".resource-panel")

      @model.bind("destroy", @remove, @)
      @model.permissions(_.bind(@show_permission, @))

    render: () ->
      return @$el

    show_permission: (model, data) ->
      _.each data, (permission, i) =>
          @$(".ability-#{permission.id} input:checkbox").attr("checked", true)

      @show_resource()

    show_resource: () ->
      @$resource_panels.each (i, resource) =>
          resource_el = $(resource)
          resource_check = @resource_check(resource_el)
          abilities = @abilities_check(resource_el)
          resource_check.attr("checked", true)
          abilities.each (i, ability) =>
              unless $(ability).attr("checked")?
                  resource_check.removeAttr("checked")

    check_permission: (event) ->
       ability_check = $(event.currentTarget)
       status = if ability_check.attr("checked") then true else false
       @fetch_permission([{
        permission_id:  @ability_id(ability_check),
        status: status }])

    check_resource: (event) ->
      resource_panel = $(event.currentTarget.parentElement)
      resource_check = @resource_check(resource_panel)
      abilities = @abilities_check(resource_panel)
      _permission = []
      abilities.each (i, ability) =>
          status = true
          if resource_check.attr("checked")?
              $(ability).attr("checked", true)
          else
              status = false
              $(ability).removeAttr("checked")

          _permission.push({permission_id: @ability_id(ability), status: status})

      @fetch_permission(_permission)

    fetch_permission: (data) ->
      @model.check_permissions(data)

    resource_check: (resource_panel) ->
      resource_panel.find(".resource>input:checkbox")

    abilities_check: (resource_panel) ->
      resource_panel.find(".abilities input:checkbox")

    ability_id: (ability) ->
      $(ability).attr("data-value-id")

    remove: () ->
      @$el.remove()

    render_group: () ->
      li = $("<li class='permission-group-list-#{@model.id}'>")
      li.html($("<a href='#permission-group-#{@model.id}' data-toggle='tab'>#{@model.get('name')}</a>"))
      li
#组权限视图列表
class PermissionGroupList extends Backbone.View
    events: {
      "click button.add-group" : "show_add_group",
      "submit form.add-group-form" : "create_shop_group",
      "click button.save-group" : "create_shop_group"
    }
    initialize: (opts) ->
      _.extend(@, opts)

      @groups.bind("reset", @all_group, @)
      @groups.bind("remove", @remove_group_view, @)
      @groups.bind("add", @add_group, @)
      @group = new Group([], @shop)
      @group_header = @$("ul.permission-groups-header")
      @group_content = @$(".permission-groups-content")
      @form = @$("form.add-group-form")

    all_group: () ->
      @groups.each (model) =>
          @add_group(model)

      @group_header.find("li>a:first").click()

    add_group: (model) ->
      model.set_url(@shop)
      permission_group_view = new PermissionGroupView({
          model: model,
          template: @permission_template
      })
      @group_content.append(permission_group_view.render())
      @group_header.append(permission_group_view.render_group())

    show_add_group: () ->
      @form.find("span.error").html("")
      @$(".group-panel").modal("show")
      @form.find("input:text").focus()

    create_shop_group: () ->
      data = @form.serialize()
      if @form.find("input:text").val().trim() == ""
          @form.find("span.error").html("不能为空！")
          false

      @group.create(data, (model, data) =>
          @groups.add(data)
          @form.find("input:text").val('')
          @$(".group-panel").modal("hide")
      )
      false

    remove_group_view: (model) ->
      model.trigger("destroy")
      @group_header.find(">li.permission-group-list-#{model.id}").remove()

class EmployeeGroup
  notice_template: $("<div class='alert alert-warning notice'>暂无雇员</div>")
  default_params: {
    el: null,
    shop: "",
    group_user_template: null
    permission_template: null
  }

  constructor: (options) ->
    $.extend(@default_params, options)

    @invite_employee = @default_params.el.find(".invite-employee")
    @employee_panle = @default_params.el.find(".employees")
    @group_panle = @default_params.el.find(".user-groups")
    @permission_group_panle = @default_params.el.find(".permission-groups")
    @permission_template = @default_params.permission_template

    @load_event()

    _.each($(".employee", @employee_panle), (el) =>
        employee_view = new EmployeeView({
            el: $(el),
            shop: @default_params.shop
        })

        employee_view.bind("remove_group_employee",
         _.bind(@group_view_list.remove_group_user, @group_view_list))

        employee_view.bind("inspect_employee",
            _.bind(@inspect_employee, @))
    )

  inspect_employee: () ->
    if $(".employee", @employee_panle).length <= 0
        @employee_panle.find(".content").html(@notice_template)

  load_event: () ->
    @bind_user_typeahead()
    @bind_invite_employee()
    @load_group()
    @load_permission_group()

  bind_user_typeahead: () ->
    new TypeaheadExtension({
      el: $("form>input:text", @invite_employee),
      source: "/search/all?search_type=users",
      field: 'login',
      select: (item)  =>
        $("form>input:text", @invite_employee).val(item.login)
        @invite_employee.find("form.form-search-user").submit()
    })

  bind_invite_employee: () ->
    form = @invite_employee.find("form.form-search-user")
    input = form.find("input[name=login]")
    form.submit(() =>
      login = input.val()
      employee = new Employee({}, @default_params.shop)
      employee.invite(login,
        (model, data) =>
          input.val('')
          @invite_notice("success", data.message)

        (model, data) =>              
          try
            message = JSON.parse(data.responseText)
          catch error

          @invite_notice("error", (message || data.responseText) )
      )
      false
    )

  invite_notice: (status, message) ->
    pnotify(text: message, type: status)

  load_group: () ->
    @group_view_list = new GroupViewList({
      el : @group_panle,
      shop: @default_params.shop,
      group_user_template: @default_params.group_user_template
    })

  load_permission_group: () ->
    @permission_group_list = new PermissionGroupList({
      el: @permission_group_panle,
      shop: @default_params.shop,
      permission_template: @permission_template,
      groups: @group_view_list.groups
    })

exports.EmployeeGroup = EmployeeGroup
