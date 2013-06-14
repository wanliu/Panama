#= require jquery
#= require backbone
#= require typeahead
#= require jquery.slides

root = window || @

class CategoryBase extends Backbone.View
    initialize: () ->
        @navigations = new CategoryList([], "")
        @is_search = false

    add_current_category: (model) ->
        return if @is_search
        if @navigations.length > 1
            _.each @navigations.models, (m) =>
                if m.get("ancestry_depth") == model.get("ancestry_depth")
                    @remove_current_category(m)
        @navigations.add(model)
        @reset_navigation()

    remove_current_category: (model) ->
        @navigations.remove(model)
        @reset_navigation()

    reset_navigation: (model) ->
        if @navigations.length > 1
            _.each @navigations.models, (m, i) =>
                if i == 0
                    $(".input_search").val(m.get("name"))
                else
                    $(".input_search").val($(".input_search").val() + "|" + m.get("name"))
        if @navigations.length == 1
            $(".input_search").val(@navigations.first().get("name"))

    remove_last_model: () ->
        @remove_current_category(@navigations.last())

    remove_current_categorys: (model) ->
        count = (@navigations.length) - 1
        `for(var i = 0 ; i <= count; i++) {
            this.remove_last_model()
        }`
        @add_current_category(model)


class CategoryList extends Backbone.Collection
    constructor: (models, shop) ->
        @url = "/shops/#{shop}/admins/categories"
        super models

    category_childrens: (data) ->
        @fetch({
            url: "#{@url}/category_children",
            data: data,
            type: "get"
        })

    category_root: () ->
        @fetch({
            url: "#{@url}/category_root"
        })


class CategoryChildrenSearch extends Backbone.View
    events:
        "keyup .input_search" : "keyup_choose"
        "click #search"       : "click_choose"
        "focus .input_search" : "on_focus"

    initialize : (options) ->
        _.extend(@, options)
        @search_el.css("padding-top","20px")
        @search_el.css("padding-bottom","20px")
        @search_el.css("z-index",8888)
        @search_el.css("background-color","white")
        @search_el.width($("#CategoryModal .modal-body").width())
        @$el = $(@search_el)
        @$(".search-query").typeahead({
            remote: "/shops/#{@shop_name}/admins/categories/category_search?q=%QUERY&limit=10",
            limit: 10
        })
        @$(".twitter-typeahead").addClass("span12 search-query")
        @$(".tt-query").after("<button type='button' class='btn' id='search'>搜索</button>")
        @$(".search-query").find(".tt-hint").addClass("span11")

    keyup_choose: (event) ->
        unless $(".input_search").val() == ""
            if event.keyCode == 13
                $(".tt-dropdown-menu").addClass("tt-is-empty")
                @click_keyup()

    click_choose: () ->
        unless $(".input_search").val() == ""
            @click_keyup()

    click_keyup: () ->
        @children_el.hide()
        _.each $(".category_root"), (c) =>
            $(c).attr("class", "category_root")
        mainView = @parentView.getMainView()
        mainView.search_category(@search_el.find(".input_search").val())

    on_focus: () ->
        $(".input_search").select()

    render: () ->
        @


class CategoryChildrenView extends Backbone.View
    tagName: "button"
    className: "btn category_children"

    events:
        "click" : "enter_children"

    initialize: (options) ->
        _.extend(@, options)
        @$el = $(@el)
        @$el.html(@model.get("name"))
        if @model.get("flag") == 1
            @$el.append("<span class='caret right'></span>")
        @$el.addClass("category-" + @model.id)

    render: () ->
        @

    enter_children: () ->
        if @model.get("flag") == 0
            @parentView.parentView.select_category(@model)
        else
            @$el.siblings(".active").removeClass("active")
            @$el.toggleClass("active")
            @model.trigger("parent_hide")
            @parentView.parentView.enter_children(@model)


class CategoryChildrenViewList extends Backbone.View
    tagName: "div"
    className: "btn-group btn-group-vertical"

    return_el: $("<button class='btn back-parent' data-value='back'>
                返回<span class='caret left'></span></button>")

    events:
        "click button.back-parent" : "back"

    initialize: (options) ->
        _.extend(@, options)
        @$el = $(@el)
        @children_id = "undefined"
        unless @model == null
            @children_id = @model.id
        @$el.addClass("children-#{@children_id}")
        unless @model.get("ancestry_depth") == 1
            @$el.append(@return_el.clone())

    all_children: (collection) ->
        if $(".children-#{@children_id}").length < 1
            @children_el.append(@$el)
        else
            $(".children-#{@children_id}").show()
        if collection.length > 0
            collection.each (model) =>
                @add_one_children(model)

    add_one_children: (model) ->
        model.bind("parent_hide", _.bind(@hide, @))
        model.bind("parent_show", _.bind(@show, @))
        @category_children_view = new CategoryChildrenView({
                parentView: @,
                model: model,
                shop_name: @shop_name,
                children_el: @children_el
            })
        @$el.append(@category_children_view.render(model).el)

    render: () ->
        @

    hide: () ->
        @$el.hide()

    show: () ->
        @$el.show()

    back: () ->
        @hide()
        @parentView.list_el.find(".category_cover:visible").hide()
        # mainView.children_el.find(".btn-group:visible").hide()
        category_base.remove_last_model()
        @model.trigger("parent_show")


class CategoryRootView extends Backbone.View
    tagName: "a"
    className: "category_root"
    events:
        "click" : "category_children"

    initialize: (options) ->
        _.extend(@, options)
        @$el = $(@el)
        @$el.html(@model.get("name"))

    render: () ->
        @

    category_children: () ->
        @children_el.empty()
        @list_el.empty()
        _.each $(".category_root"), (c) =>
            $(c).attr("class", "category_root")
        @$el.addClass("on")
        category_base.is_search = false
        category_base.remove_current_categorys(@model)

        mainView = @parentView.getMainView()
        mainView.attach_model(@model)


class MainView extends Backbone.View
    initialize: (options) ->
        _.extend(@, options)
        @$el = $(@el)

    attach_model: (model) ->
        if model != null
            @enter_children(model)

    select_category: (model) ->
        category_base.add_current_category(model)
        $(".category_select").attr("data-select", model.id)

        category_el = @list_el.find(".category_cover:visible")
        category_btn = category_el.find(".category-#{model.id}")
        category_btn.parent().parent().siblings().find(".select_category.active").removeClass("active")
        category_btn.toggleClass("active")

        children_el = @children_el.find(".btn-group:visible")
        children_btn = children_el.find(".category-#{model.id}")
        children_btn.siblings(".active").removeClass("active")
        children_btn.toggleClass("active")

    search_category: (search_value) ->
        search_value = $.trim(search_value)
        category_name = (search_value.split("|"))[search_value.split("|").length-1]
        @list_el.empty()
        @children_el.empty()
        @category_list = new CategoryList([], @shop_name)
        @category_list.bind("reset", @refresh_list, @)
        @category_list.bind("reset", @render, @)
        @category_list.category_childrens({ category_name: category_name })

    refresh_list: (collection) ->
        category_base.is_search = true
        @list_view = new CategoryListView({
            parentView: @,
            model: null,
            shop_name: @shop_name,
            list_el: @list_el
        })
        @list_view.all_children(collection)

    enter_children: (model) ->
        category_base.add_current_category(model)
        @children_view = new CategoryChildrenViewList({
            parentView: @,
            model: model,
            shop_name: @shop_name,
            children_el: @children_el
        })
        @list_view = new CategoryListView({
            parentView: @,
            model: model,
            shop_name: @shop_name,
            list_el: @list_el
        })
        @category_list = new CategoryList([], @shop_name)
        @category_list.bind("reset", @all_children, @)
        @category_list.bind("reset", @render, @)
        @category_list.category_childrens({ category_name: model.get("name") })

    all_children: (collection) ->
        @list_view.all_children(collection)
        @children_view.all_children(collection)

    render: () ->
        @children_el.show()
        # @list_el.show()
        @list_el.find(".slides").slidesjs({
            width: 200,
            height: 133,
            navigation: false,
            pagination: false
        })
        @


class CategoryView extends Backbone.View
    initialize : (options) ->
        _.extend(@, options)
        @category_root_el = @el.find(".category_roots")
        @category_children_el = @el.find(".category_buttons")
        @category_list_el = @el.find(".category_list")
        @search_el = @el.find(".search")
        @show_root()

    show_root: () ->
        @category_root = new CategoryList([], @shop_name)
        @category_root.bind("reset", @all_root, @)
        @category_root.bind("reset", @new_search, @)
        @category_root.bind("reset", @render, @)
        @category_root.category_root()

    new_search: () ->
        search_view = new CategoryChildrenSearch({
            parentView: @,
            model: @model,
            search_el: @search_el,
            children_el: @category_children_el,
            list_el: @category_list_el,
            shop_name: @shop_name
        })

    all_root: (collection) ->
        collection.each (model) =>
            @add_one_root(model)

    add_one_root: (model) ->
        category_root_view = new CategoryRootView({
            parentView: @,
            model: model,
            children_el: @category_children_el,
            list_el: @category_list_el,
            shop_name: @shop_name
        })
        @category_root_el.append(category_root_view.render().el)

    getMainView: () ->
        @mainView ||= new MainView({
            shop_name: @shop_name,
            children_el: @category_children_el,
            list_el: @category_list_el
        })

    render: () ->
        search_value = $(button).text()
        if search_value == "" || search_value == "Noselected"
            @getMainView().search_category("_products_root")
        else
            $(".input_search").val(search_value)
            @getMainView().search_category(search_value)
        @


class CategoryDetailView extends Backbone.View
    tagName: 'div'
    className: 'category_detail'
    detail_template: _.template($('#list-template').html())

    initialize: (options) ->
        _.extend(@, options)
        @$el = $(@el)

    events:
        "click .enter_children" : "enter_children"
        "click .select_category" : "select_category"

    enter_children: () ->
        @model.trigger("parent_hide")
        @parentView.parentView.enter_children(@model)

    select_category: () ->
        @parentView.parentView.select_category(@model)

    render: () ->
        @$el.html(@detail_template(@model.toJSON()))
        @


class CategoryListView extends Backbone.View
    tagName: 'div'
    className: 'category_cover'

    initialize: (options) ->
        _.extend(@, options)
        @$el = $(@el)
        @list_id = "undefined"
        unless @model == null
            @list_id = @model.id
        @$el.addClass("list-#{@list_id}")

    all_children: (collection) ->
        if $(".list-#{@list_id}").length > 0
            $(".list-#{@list_id}").show()
        else
            @list_el.append(@$el)
            if collection.length > 0
                collection.each (model) =>
                    @add_one_children(model)
        @show_tip()

    add_one_children: (model) ->
        model.bind("parent_hide", _.bind(@hide, @))
        model.bind("parent_show", _.bind(@show, @))
        @category_detail_view = new CategoryDetailView({
                parentView: @,
                model: model,
                list_el: @list_el
                shop_name: @shop_name
            })
        $(@el).append(@category_detail_view.render().el)

    show_tip: () ->
        if @list_el.find(".category_cover:visible").children().length == 0
            @list_el.append('<div class="alert fade in no-result" style="display: none;">
            <strong>没有搜索结果，试着换一个搜索词吧！</strong>
        </div>')
            @list_el.find(".no-result").show()
        else
            @list_el.find(".no-result").hide()

    hide: () ->
        @$el.hide()

    show: () ->
        @$el.show()

    back: () ->
        @hide()
        @model.trigger("parent_show")

    render: () ->
        @

category_base = new CategoryBase()
root.CategoryView = CategoryView
