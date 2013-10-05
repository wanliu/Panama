root = window || @

class SearchUserView extends Backbone.View
	
	events: 
		"click .search_user" : "query_user"

	initialize: () ->
		@template1 = Hogan.compile($("#buyer_base_template").html())
		@template2 = Hogan.compile($("#seller_base_template").html())
		@notice = $("<div class='error'><span>您搜索的区域暂时没有成员～～～～</span></div>")

	query_user: () ->
		values = $(@el).serializeArray()
		data = {}
		_.each values, (v) -> data[v.name] = v.value

		$.ajax({
			type: "post",
			dataType: "json",
			data:  data,
			url: "/yellow_page/search"
			success: (datas) =>
				@render(datas)
		})

	render: (datas) =>
		if datas.length == 0
			$(@el.parentElement.parentElement).find(".wrapper").append(@notice)
		else
			$(@el.parentElement.parentElement).find(".wrapper > div").remove()
			_.each datas, (data) =>
				tpl = if data.service_id = 1 
					@template1
				else
					@template2
				$(@el.parentElement.parentElement).find(".wrapper").append(tpl.render(data))


class SearchUserViewList extends Backbone.View

	initialize: () ->
		_.each $("form.address_from_post"), (el) ->
			new SearchUserView({el: el})

root.SearchUserViewList = SearchUserViewList
