define ["jquery", "backbone", "exports"], ($, Backbone, exports) ->
    class Category extends Backbone.View


        initialize : (options) ->
            _.extend(@, options)
            @$(".categorys_root").on('click', _.bind(@root_click, @))


        root_click : (event) ->
            $.ajax
                type: "get"
                dataType: "json"
                data: {"category_name": $(event.currentTarget).html()}
                url: "/shops/#{@shop_name}/admins/categories/category_children"
                success : (data) =>
                    @$(".category_buttons").html("")
                    @$(".category_buttons").append(@template.render({categorys: data}))


    exports.Category = Category
    exports