define ['jquery', 'backbone', 'exports'], ($, Backbone, exports) ->

	class PeopleSideView extends Backbone.View
		TOP_POSITION = 131

		initialize: (@options) ->
			$(document).scroll(_.bind(@autoScroll, @))
			@$el.bind('fixed', _.bind(@onFixed, @))
			@$el.bind('unfixed', _.bind(@onUnfixed, @))


		autoScroll: (event) ->
			if $(document).scrollTop() > TOP_POSITION
				@$el.addClass("affix")
				@$el.trigger('fixed')
			else
				@$el.removeClass("affix")
				@$el.trigger('unfixed')

		onFixed: () ->
			@$(">.img-polaroid")
				.width(40)
				.height(40)
				.css('float', 'left')
				.css('margin-right', 10)

		onUnfixed: () ->
			@$(">.img-polaroid")
				.width(200)
				.height(200)

	exports.PeopleSideView = PeopleSideView
	exports

