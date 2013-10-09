root = window || @

class SearchUserView extends Backbone.View
	
	events: 
		"click .search_user" : "form_query_user"
		"click .hot_city_search" : "hot_city_search"

	initialize: () ->
		@get_hot_cities()
		@buyer_template = Hogan.compile($("#buyer_base_template").html())
		@seller_template = Hogan.compile($("#seller_base_template").html())
		@hot_city_template = Hogan.compile("<a id={{ area_id }} href='#' class='hot_city_search'>{{ name }}</a>&nbsp;")
		@notice = $("<div class='alert'>
			 			<button type='button' class='close' data-dismiss='alert'>&times;</button>
						<span>您搜索的区域暂时没有成员～～～～</span>
					</div>")

	judge_type: () -> 
		type = ""
		if $(@el).hasClass("newer")
			type = "new_user"
		else if $(@el).hasClass("buyer")
			type = "buyer_user"
		else
			type = "seller_user"

	get_hot_cities: () ->
		type = @judge_type()
		$.ajax({
			dataType: "json",
			type: "get",
			data: {type: type},
			url: "yellow_page/hot_city_name",
			success: (datas) =>
				_.each datas, (data) =>
					@$(".hot_city span").append(@hot_city_template.render(data))
		})

	hot_city_search: (event) ->
		id = event.currentTarget.id
		type = @judge_type()
		$.ajax({
			dataType: "json",
			type: "get",
			data:{address: {area_id: id,type: type}} ,
			url: "yellow_page/search",
			success: (datas) =>
				@render(datas)
				new YellowInfoPreviewList({el : @el })
		})
		return false

	form_query_user: () ->
		values = @$("form.address_from_post").serializeArray()
		data = {}
		_.each values, (v) -> data[v.name] = v.value
		
		$.ajax({
			type: "get",
			dataType: "json",
			data:  data,
			url: "/yellow_page/search"
			success: (datas) =>
				@render(datas)
				new YellowInfoPreviewList({el : @el })
		})
		return false

	render: (datas) =>
		if datas.length == 0
			$(@notice).insertBefore(@$(".wrapper"))
		else
			@$(".alert").fadeOut()
			@$(".wrapper > div").animate({left: '20px'},'slow',@$(".wrapper > div").fadeOut());
			_.each datas, (data) =>
				tpl = if data.service_id == 1 
					@buyer_template
				else
					@seller_template
				@$(".wrapper").append(tpl.render(data))


class SearchUserViewList extends Backbone.View

	initialize: () ->
		_.each $(".base_info"), (el) ->
			new SearchUserView({el: el})

root.SearchUserViewList = SearchUserViewList
