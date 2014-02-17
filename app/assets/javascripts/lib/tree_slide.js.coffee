
root = window || @

class root.TreeSlide extends Backbone.View

	events:
		"click a[data-toggle='slide']": "toggleSlide"
		# "mouseenter a[data-toggle='slide']": "openSlide"

	openFirstRoot: () ->
		@$("a[data-toggle='slide']").eq(0).trigger('click')

	toggleSlide: (e) ->
		$collapse_target = @$(@$(e.currentTarget).attr('href'))
		if $collapse_target.toggleClass("in").hasClass("in")
			$collapse_target.css('height', 'auto');
			@$(e.currentTarget).find('i').removeClass("icon-caret-right").addClass("icon-caret-down")
			@foldOtherRoot($collapse_target)
		else
			$collapse_target.css('height', '0px');
			@$(e.currentTarget).find('i').removeClass("icon-caret-down").addClass("icon-caret-right")
		false

	foldOtherRoot: (el) ->
		target_tree = el.parents(".tree-group").last()
		target_tree.siblings().each (i, elem) =>
			if $(elem).find(">ul").hasClass("in")
				$(elem).find(">ul").removeClass("in").css('height', '0px')
				$(elem).find('i').removeClass("icon-caret-down").addClass("icon-caret-right")

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

