
root = window || this

class TreeSlide extends Backbone.View

	events:
		"click a[data-toggle='slide']": "toggleSlide"
		# "mouseenter a[data-toggle='slide']": "openSlide"

	toggleSlide: (e) ->
		$collapse_target = @$(@$(e.target).attr('href'))
		if $collapse_target.toggleClass("in").hasClass("in")
			$collapse_target.css('height', 'auto');
			@$(e.target).find('i').removeClass("icon-caret-right").addClass("icon-caret-down")
		else
			$collapse_target.css('height', '0px');
			@$(e.target).find('i').removeClass("icon-caret-down").addClass("icon-caret-right")
		false

	openSlide: (e) ->
		$collapse_target = @$(@$(e.target).attr('href'))
		unless $collapse_target.hasClass("in")
			$collapse_target.addClass("in")
							.css("margin-left", "200px")
							.animate("margin-left": 0)

			setTimeout( ()=>
				@extractElements(@elementLine(e))
			, 100)

	isContainer: (e) ->
		@$(e.target).parent("li").find(@currentElement(e)).length > 0

	extractElements: (elements) ->
		removes = _(@$el.find("ul.in.collapse")).difference(elements)
		$(elem).removeClass("in") for elem in  removes


	elementLine: (e) ->
		parents = @$(e.target).parents("ul.collapse").toArray()
		parents.concat(@$(e.target).parent().find(">ul.in.collapse").toArray())

	currentElement: (e) ->
		console.log e.currentTarget, document.elementFromPoint(e.pageX, e.pageY)
		document.elementFromPoint(e.pageX, e.pageY)


root.TreeSlide = TreeSlide