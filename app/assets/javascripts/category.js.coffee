define ["jquery", "backbone", "exports", "jquery.slides"], ($, Backbone, exports) ->
    class Category extends Backbone.View


        initialize : (options) ->
            _.extend(@, options)
            @$(".categorys_root").on('click', _.bind(@root_click, @))
            

        root_click : (event) ->
            @target_button = $(event.target)
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
                        @$(".category-preview").html(@template.render({categorys: data}))
                        @$(".category-preview .category_buttons .btn").on('click', _.bind(@root_click, @))
                        
                        $(".slides").slidesjs({
                            width: 200,
                            height: 133,
                            navigation: false,
                            pagination: false
                        })
                    else if data == null
                        init_top = $(".category_detail:first").offset().top
                        scroll_offset = $("#"+@target_button.attr("id")).offset();
                        $("#category_list").animate({
                           scrollTop : scroll_offset.top-init_top
                        },100);

    exports.Category = Category
    exports