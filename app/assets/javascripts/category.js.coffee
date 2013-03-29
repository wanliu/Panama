define ["jquery", "backbone", "exports", "typeahead", "jquery.slides"], 
($, Backbone, exports, typeahead) ->

    class CategoryBase extends Backbone.View

        initialize: () ->
            @navigations = new CategoryList([], "")

        add_current_category: (model) ->
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

        refresh_category_list: (model, shop_name) ->
            new CategoryListView({
                model: model,
                shop_name: shop_name
            })

    
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


    class CategoryChildrenView extends Backbone.View

        events: {
            "click" : "children"
        }

        tagName: "button"

        className: "btn category_children"

        initialize: (options) ->
            _.extend(@, options)
            @$el = $(@el)
            @$el.html(@model.get("name"))
            if @model.get("flag") == 1
                @$el.append("<span class='caret right'></span>")
            @$el.addClass("category-"+@model.get('id'))

        render: () ->
            @$el

        children: () ->
            category_base.add_current_category(@model)
            if @model.get("flag") == 1
                @model.trigger("parent_hide")
                str = $(this.el).parent().attr("class").split("-")[4]
                $(".category_list").attr("back_parent","list-#{str}")
                new CategoryChildrenViewList({
                    model: @model,
                    shop_name: @shop_name,
                    children_el: @children_el
                })
            
            @$el.siblings(".active").removeClass("active")
            @$el.toggleClass("active")

            id = @$el.attr("class").split(" ")[2]
            if $(".category_list .#{id}")[0] != $(".category_cover").find("button.select_category.active")[0]
                $(".category_cover").find("button.select_category.active").removeClass("active")
            $(".category_list .#{id}").toggleClass("active")
            
            category_base.refresh_category_list(@model, @shop_name)


    class CategoryChildrenSearch extends Backbone.View
        events: {
            "keyup .input_search" : "keyup_choose"
            "click #search"       : "click_choose"
            "focus .input_search" : "on_focus"
        }

        initialize : (options) ->
            _.extend(@, options)
            @$el = $(@search_el)
            @$(".search-query").typeahead({
                remote: "/shops/#{@shop_name}/admins/categories/category_search?q=%QUERY&limit=10",
                limit: 10
            })
            @$(".twitter-typeahead").addClass("span12 search-query")
            @$(".tt-query").after("<button type='button' class='btn' id='search'>搜索</button>")

        keyup_choose: (options) ->
            unless $(".input_search").val() == ""
                if event.keyCode == 13
                    $(".tt-dropdown-menu").addClass("tt-is-empty")
                    @click_keyup()

        click_choose: (options) ->
            unless $(".input_search").val() == ""
                @click_keyup()

        click_keyup: (options) ->
            # @children_el.html("")
            @children_el.hide()
            _.each $(".category_root"), (c) =>
                $(c).attr("class", "category_root")

            category_base.refresh_category_list(null, @shop_name)

        on_focus: (options) ->
            $(".input_search").select()


    class CategoryChildrenViewList extends Backbone.View
        return_el: $("<button class='btn back-parent' data-value='back'>
                        返回<span class='caret left'></span>
                      </button>")

        events: {
            "click button.back-parent" : "back"
        }

        className: "btn-group btn-group-vertical"

        initialize: (options) ->
            _.extend(@, options)
            @category_list = new CategoryList([], @shop_name)
            @category_list.bind("reset", @all_children, @)
            @category_list.category_childrens({ category_name: @model.get("name") })
            @$el = $(@el)
            @$el.addClass("children-#{@model.get('id')}")
            unless @model.get("ancestry_depth") == 1
                @$el.append(@return_el.clone())

        all_children: (collection) ->
            if $(".children-#{@model.get('id')}").length < 1
                @children_el.append(@$el)
            else 
                $(".children-#{@model.get('id')}").show()
            if collection.length > 0
                collection.each (model) =>
                    @add_one_children(model)

        add_one_children: (model) ->
            model.bind("parent_hide", _.bind(@hide, @))
            model.bind("parent_show", _.bind(@show, @))

            @category_children_view = new CategoryChildrenView({
                    model: model,
                    shop_name: @shop_name,
                    children_el: @children_el
                })
            @$el.append(@category_children_view.render(model))
            

        render: () ->
            @$el

        hide: () ->
            @$el.hide()

        show: () ->
            @$el.show()

        back: () ->
            @hide()
            category_base.remove_last_model()
            @model.trigger("parent_show")

            $(".category_cover.list-#{@model.get('id')}").hide()
            $(".#{$('.category_list').attr('back_parent')}").show()                    

    class CategoryRootView extends Backbone.View
        events: {
            "click" : "category_children"
        }

        tagName: "a"

        className: "category_root"

        initialize: (options) ->
            _.extend(@, options)
            @$el = $(@el)
            @$el.html(@model.get("name"))

        render: () ->
            @$el

        category_children: () ->
            # @children_el.html("")
            @children_el.hide()
            _.each $(".category_root"), (c) =>
                $(c).attr("class", "category_root")
            @$el.addClass("on")
            category_base.remove_current_categorys(@model)
            new CategoryChildrenViewList({
                    model: @model,
                    children_el: @children_el,
                    shop_name: @shop_name
                })
            $(".category_buttons").show()
            
            category_base.refresh_category_list(@model, @shop_name)

    class Category extends Backbone.View

        initialize : (options) ->
            _.extend(@, options)
            @category_root_el = @el.find(".category_roots")
            @category_children_el = @el.find(".category_buttons")
            @search_el = @el.find(".search")
            @category_root = new CategoryList([], @shop_name)
            @category_root.bind("reset", @all_root, @)
            @category_root.category_root()

            new CategoryChildrenSearch({
                model: @model,
                search_el: @search_el,
                children_el: @category_children_el,
                shop_name: @shop_name
            })

        all_root: (collection) ->
            collection.each (model) =>
                @add_one_root(model)

        add_one_root: (model) ->
            @category_root_view = new CategoryRootView({
                model: model,
                children_el: @category_children_el,
                shop_name: @shop_name
            })
            @category_root_el.append(@category_root_view.render())


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
            str = $(@el).parent().attr("class").split(" ")[1]
            $(".category_list").attr("back_parent",str)
            $("button.category-#{@model.get('id')}").click()
            # category_base.refresh_category_list(@model, @shop_name)

        select_category: () ->
            $(".category_buttons").find("button.category-#{@model.get('id')}").click()

        render: () ->
            @$el.html(@detail_template(@model.toJSON()))
            @el


    class CategoryListView extends Backbone.View
        tagName: 'div'
        className: 'category_cover'
        
        initialize: (options) ->
            _.extend(@, options)
            @$el = $(@el)
            list_id = "list-undefined"
            if @model != null
                @category_name = @model.get("name")
                list_id = "list-#{@model.get('id')}"
                return if @model.get("flag") == 0
            else
                $(".list-undefined").remove()
                search_value = $.trim($(".input_search").val())
                @category_name = (search_value.split("|"))[search_value.split("|").length-1]
            
            @select_list = ".category_cover.#{list_id}"
            $(".category_cover:visible").hide()
            if $(@select_list).length > 0
                $(".no-result").hide()
                $(@select_list).show()
            else
                debugger
                @$el.addClass(list_id)
                @new_list(options)

        new_list: (options) ->
            @CategoryDetails = new CategoryList([], @shop_name)
            @CategoryDetails.bind("reset", @all_children, @)
            @CategoryDetails.bind("reset", @render, @)
            @model = @CategoryDetails.category_childrens({ category_name: @category_name })
        
        all_children: (collection) ->
            if collection.length > 0
                collection.each (model) =>
                    @add_one_children(model)

        add_one_children: (model) ->
            @category_detail_view = new CategoryDetailView({
                    model: model,
                    shop_name: @shop_name
                })
            $(@el).append(@category_detail_view.render())

        show_tip: () ->
            if $(".category_list").find(".category_cover:visible").children().length == 0 
                $(".no-result").show()
            else
                $(".no-result").hide()

        render: () ->
            $(".category_list").append(@el)
            $(".slides").slidesjs({
                width: 200,
                height: 133,
                navigation: false,
                pagination: false
            })
            @show_tip()
            @


    category_base = new CategoryBase()

    exports.Category = Category
    exports