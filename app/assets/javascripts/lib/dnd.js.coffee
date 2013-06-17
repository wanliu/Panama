#= require jquery
#= require jquery-ui
#= require backbone
#= require lib/abstract

exports = window || @

class DraggableView extends AbstractView

	constructor: (@options) ->
		super @options
		@draggable ||= @options['draggable']
		$(@el).draggable(@draggable)


class DroppableView extends AbstractView

	constructor: (@options) ->
		super @options
		@droppable ||= @options['droppable']
		$(@el).droppable(@droppable)

class DNDView extends Backbone.View

	constructor: (@options) ->
		super @options

		_dropabble = _(@droppable || @options['droppable']).clone()
		@draggable ||= @options['draggable']
		if	_dropabble?
			_dropabble['drop'] ||= $.proxy(@doDroppable, @)
			target = if _dropabble['target']?
				_target = _dropabble['target']
				delete _dropabble.target
				$(@el).find(_target)
			else
				$(@el)

			target.droppable _dropabble

		$(@el).draggable(@draggable) if @draggable?

	doDroppable: (event, ui) ->
		@onDroppable.call(@, event, ui) if @onDroppable?


exports.DraggableView = DraggableView
exports.DroppableView = DroppableView
exports.DNDView = DNDView
exports