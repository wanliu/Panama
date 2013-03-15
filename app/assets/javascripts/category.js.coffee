define ["jquery", "backbone", "exports"], ($, Backbone, exports) ->

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

        render: () ->
            @$el

        children: () ->
            @model.trigger("parent_hide")
            category_children_view = new CategoryChildrenViewList({
                model: @model,
                shop_name: @shop_name,
                children_el: @children_el
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
            @$el.append(@return_el.clone())
            #@return_el.bind("click", _.bind(@back, @))


        all_children: (collection) ->
            @children_el.append(@$el)
            collection.each (model) =>
                @add_one_children(model)


        add_one_children: (model) ->
            model.unbind("parent_hide")
            model.unbind("parent_show")
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
            new CategoryChildrenViewList({
                    model: @model,
                    children_el: @children_el,
                    shop_name: @shop_name
                })


    class Category extends Backbone.View

        initialize : (options) ->
            _.extend(@, options)
            @category_root_el = @el.find(".category_roots")
            @category_children_el = @el.find(".category_buttons")

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


    exports.Category = Category
    exports