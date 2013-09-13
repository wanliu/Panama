
root = window || @

# 抽象出的无限滚动加载视图
class InfiniteScrollView extends Backbone.View
	offset: 0,
	limit: 10,
	msg_tip: '<div class="text-center">亲，已经到底啦</div>'

	initialize: (options) ->
		_.extend(@, options)
		@$el = $(@el)
		@fetch()
		$(window).scroll(_.bind(@scroll_load, @))

	fetch: () ->
		$(@msg_el).show()
		$.ajax(
			url: @fetch_url,
			dataType: "json",
			data: {
				shop_id: @shop_id,
				offset: @offset,
				limit: @limit
			},
			success: (data) =>
				if data.length == 0
					$(@msg_el).html(@msg_tip)
				else if data.length == @limit
					$(@msg_el).hide()
					@add_columns(data)
					@offset += @limit
				else
					@add_columns(data)
					@offset += @limit
					$(@msg_el).html(@msg_tip)
		)

	min_column_el: () ->
		columns = $(@sp_el).find(".columns>.column")
		cls = _.map columns, (c) -> $(c).height()
		$(columns[cls.indexOf(_.min(cls))])

	add_columns: (data) ->
		_.each data, (c) =>
			# @before_add(c)
			# @min_column_el().append(@template.render(c))
			# @add_column(c)
			@add_one(c)

	before_add: (c) ->

	add_column: (c) ->
		# 由具体的子视图实现

	scroll_load: () ->
		if $(@msg_el).css("display") != "block"
			sp_height = $(@sp_el).offset().top + $(@sp_el).height()
			w_height = $(window).height() + $(window).scrollTop()
			if sp_height <= w_height
				clearTimeout(@timeout_id) if @timeout_id
				@timeout_id = setTimeout _.bind(@fetch, @), 250


root.InfiniteScrollView = InfiniteScrollView
