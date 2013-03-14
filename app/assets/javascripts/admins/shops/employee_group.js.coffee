#author: huxinghai
#邀请雇员与雇加入组别

define(["jquery", "user_typeahead", "jquery-ui"
 ,"twitter/bootstrap/tab", "backbone", "hogan"],
 ($, UserTypeahead, jqueryui, tab, Backbone) ->

    #组权限模型
    class Group extends Backbone.Model
        set_url: (shop) ->
            @url = "/shops/#{shop}/admins/groups"
        constructor: (attrs, shop) ->
            @set_url(shop)
            super attrs

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
                url: "#{@url}/destroy",
                type: "delete"
                data: {user_id: @get('user_id')},
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
            this.fetch({
                url: "#{@url}/invite",
                data: {login: login},
                type: 'post',
                success: callback,
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
            $("img.avatar", @$el).attr("src", @model.get('icon'))
            @model.bind("remove_employee_el", _.bind(@remove_el, @))

        render: () ->
            @$el

        remove: () ->
            @model.group_remove_employee({
                    shop_user_id: @model.id,
                    shop_group_id: @group_id
                }, (data, xhr) =>
                    @remove_el()

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
            @$el.attr("id", "group-#{@group.get('name')}")
            @bind_droppable()

            @employee_list = new EmployeeList({}, @shop)
            @employee_list.bind("reset", @all_employee, @)
            @employee_list.bind("add", @add_employee, @)
            @employee = new Employee({}, @shop)
            @group.bind("group_remove_employee", _.bind(@group_remove_employee, @))

        bind_droppable: () ->
            @$el.droppable({
                drop: $.proxy(@drop, @)
            })

        drop: (event, ui) ->
            employee_id = ui.helper.attr("data-value")
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

    #组视图
    class GroupView extends Backbone.View
        tagName: "li"
        template: Hogan.compile("<a href='#group-{{name}}' data-toggle='tab'>{{name}}</a>")
        events: {
            "click" : "show_tab"
        }
        initialize: (options) ->
            _.extend(@, @options)
            @model.bind("show_tab", @show_tab, @)

        render: () ->
            $(@el).html(@template.render(@model.toJSON()))

        show_tab:  () ->
            @trigger("load_employee")
            $(@el).find("a").tab("show")

    #组视图列表
    class GroupViewList extends Backbone.View
        default_opts: {
            shop: "",
            group_user_template: null
        }

        initialize: (el, options) ->
            @el = el
            _.extend(@default_opts, options)
            @groups = new GrupList({}, @default_opts.shop)
            @$group_header = @el.find('ul.user-group-header')
            @$group_content = @el.find('.user-group-content')

            @groups.bind("reset", @find_all, @)
            @groups.fetch()

        find_all: (collection) ->
            collection.each((model) =>
                @add_group(model)
            )
            @groups.first().trigger("show_tab")

        add_group: (model) ->
            #组视图
            group_view = new GroupView({
                model: model
            })
            @$group_header.append(group_view.render())

            #组的雇员视图
            group_employee_view = new GroupEmployeeListView({
                group: model,
                employee_template: @default_opts.group_user_template,
                shop: @default_opts.shop
            })
            group_view.bind("load_employee", _.bind(group_employee_view.load_employee,
                group_employee_view))
            @$group_content.append(group_employee_view.render())

        remove_group_user: (user_id) ->
            @groups.each((model) =>
                model.trigger("group_remove_employee", user_id)
            )

        render: () ->

    #雇员视图
    class EmployeeView extends Backbone.View
        events: {
            "click .remove" : "remove"
        }
        initialize: (options) ->
            _.extend(@, options)
            @model = new Employee({user_id: parseInt(@el.attr("data-value"))}, @shop)
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
            @model.destroy((data) =>
                @el.remove()
                @trigger("remove_group_employee", @model.get("user_id"))
                @trigger("inspect_employee")
            )

    class EmployeeGroup
        notice_template: $("<div class='alert alert-warning notice'>暂无雇员</div>")
        default_params: {
            el: null,
            shop: "",
            group_template: null,
            group_user_template: null
        }

        constructor: (options) ->
            $.extend(@default_params, options)

            @invite_employee = @default_params.el.find(".invite-employee")
            @employee_panle = @default_params.el.find(".employees")
            @group_panle = @default_params.el.find(".user-groups")
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

        bind_user_typeahead: () ->
            new UserTypeahead(@invite_employee.find("form>input:text"))

        bind_invite_employee: () ->
            form = @invite_employee.find("form.form-search-user")
            input = form.find("input[name=login]")
            form.submit(() =>
                @invite_notice("success", "正在发送信息，请等待...")
                login = input.val()
                employee = new Employee({}, @default_params.shop)
                employee.invite(login,
                    (model, data) =>
                        @invite_notice("success", data.message)

                    (model, data) =>
                        @invite_notice("error", data.message)
                )
                false
            )

        invite_notice: (status, message) ->
            reverse_status = if status=="success" then "error" : "success"
            alert = @invite_employee.find("form.form-search-user .alert-message")
            alert.removeClass("alert-#{reverse_status}").addClass("alert-#{status}")
            alert.find(".content").html(message)
            alert.show()

        load_group: () ->
            @group_view_list = new GroupViewList(@group_panle, {
                shop: @default_params.shop,
                group_template: @default_params.group_template,
                group_user_template: @default_params.group_user_template
            })

    EmployeeGroup
)