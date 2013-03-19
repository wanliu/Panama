define ["jquery", "backbone", "exports", "jquery.slides"], ($, Backbone, exports) ->

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

        reset_navigation: () ->
            if @navigations.length > 1
                navigation.html("")
                _.each @navigations.models, (m, i) =>
                    if i == 0
                        navigation.append(m.get("name"))
                    else
                        navigation.append(" - " + m.get("name"))
            if @navigations.length == 1
                navigation.html(@navigations.first().get("name"))

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
                url: "#{@url}/category_page"
            })

    class CategoryChildrenView extends Backbone.View

        events: {
            "click" : "children"
        }
        tagName: "button"

        className: "btn"

        initialize: (options) ->
            _.extend(@, options)
            @$el = $(@el)
            @$el.html(@model.get("name"))
            if @model.get("status") == 1
                 @$el.append("<span class='caret right'></span>")

        render: () ->
            @$el

        children: () ->
            category_base.add_current_category(@model)
            if @model.get("status") == 1
                @model.trigger("parent_hide")
                category_children_view = new CategoryChildrenViewList({
                    model: @model,
                    shop_name: @shop_name,
                    children_el: @children_el
                })

                new CategoryListView({
                    model: @model,
                    shop_name: @shop_name
                })

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
            @children_el.append(@$el)
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
            @children_el.html("")
            category_base.remove_current_categorys(@model)
            new CategoryChildrenViewList({
                    model: @model,
                    children_el: @children_el,
                    shop_name: @shop_name
                })

            new CategoryListView({
                    model: @model,
                    shop_name: @shop_name
            })


    navigation = ""

    class Category extends Backbone.View

        initialize : (options) ->
            _.extend(@, options)
            @category_root_el = @el.find(".category_roots")
            @category_children_el = @el.find(".category_buttons")
            navigation = @el.find(".navigation")
            @category_root = new CategoryList([], @shop_name)
            @category_root.bind("reset", @all_root, @)
            @category_root.category_root()

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
        el: $(".category_cover")

        detail_template: _.template($('#list-template').html())

        initialize: (options) ->
            @listenTo(@model, 'change', @render)
            @listenTo(@model, 'destroy', @remove)

        render: () ->
            @$el = $(@el)
            @$el.append(@detail_template(@model.toJSON()))
            @$(".slides").slidesjs({
                width: 200,
                height: 133,
                navigation: false,
                pagination: false
            });
            @


    class CategoryListView extends Backbone.View
        el: $(".category_list")           

        initialize: (options) ->
            _.extend(@, options)
            @CategoryDetails = new CategoryList([], @shop_name)
            @CategoryDetails.bind("reset", @all_children, @)
            @CategoryDetails.category_childrens({ category_name: @model.get("name") })
            @$el = $(@el)

        all_children: (collection) ->
            if collection.length > 0
                $(".category_cover").html("")
                collection.each (model) =>
                    @add_one_children(model)

        add_one_children: (model) ->
            @category_detail_view = new CategoryDetailView({
                    model: model,
                    shop_name: @shop_name
                })
            @$el.append(@category_detail_view.render(model))

    # root_click : (event) ->
    #     @target_button = $(event.target)
    #     children_name = $(event.currentTarget).attr("data-value")
    #     flag = false
    #     if "back" is children_name
    #         children_name = @$(".category-preview .category_buttons .btn").last().attr("data-value")
    #         flag = true
    #     $.ajax
    #         type: "get"
    #         dataType: "json"
    #         data: {"category_name": children_name, "flag": flag}
    #         url: "/shops/#{@shop_name}/admins/categories/category_children"
    #         success : (data) =>
    #             if data != null && data.length > 0 
    #                 @$(".category-preview").html(@template.render({categorys: data}))
    #                 @$(".category-preview .category_buttons .btn").on('click', _.bind(@root_click, @))
                    
    #                 $(".slides").slidesjs({
    #                     width: 200,
    #                     height: 133,
    #                     navigation: false,
    #                     pagination: false
    #                 })
    #             else if data == null
    #                 init_top = $(".category_detail:first").offset().top
    #                 scroll_offset = $("#"+@target_button.attr("id")).offset();
    #                 $("#category_list").animate({
    #                    scrollTop : scroll_offset.top-init_top
    #                 },100);

    category_base = new CategoryBase()
    exports.Category = Category
    exports