define ["jquery", "backbone", "exports"], ($, Backbone, exports) ->
    class Category extends Backbone.View


        initialize : (options) ->
            _.extend(@, options)
            @$(".categorys_root").on('click', _.bind(@root_click, @))
            

        root_click : (event) ->
            children_name = $(event.currentTarget).attr("data-value")
            flag = false
            if "back" is children_name
                children_name = @$(".category-preview .category_buttons .btn").last().attr("data-value")
                flag = true
            $.ajax
                type: "get"
                dataType: "json"
                data: {"category_name": children_name, "flag": flag}
                url: "/shops/#{@shop_name}/admins/categories/category_children"
                success : (data) =>
                    if data != null && data.length > 0 
                        @$(".category-preview").html("")
                        @$(".category-preview").append(@template.render({categorys: data}))
                        @$(".category-preview .category_buttons .btn").on('click', _.bind(@root_click, @))


    exports.Category = Category
    exports