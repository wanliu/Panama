define ['jquery', 'backbone', 'underscore', 'exports'], ($, Backbone, _, exports)->
	class exports.tableCreater extends Backbone.View
		#schema:
		#	depth: [color, size]    #维度
		#	structure: [[red, blue, white], [M, ML, XL, XXL], ....]  #初始表结构对象
		#	data: [price, quantity]  #数据字段
		constructor: (el, schema)->
			@render(el)

			@schema = schema
			@structure = @schema.structure
			@parseTable()

		render: (el)->
			@el = $("<table></table>")
			el.append(@el)

		parseTable: ()->
			@tableView = new tableUnitView(
				structure  : @structure
				position   : [-1, 0]
				isRoot     : true
				parent_el  : @el)

		# addRow: (Row, depth)->
		# 	@forwardAdd()
		# 	@backwardAdd()

		# removeRow: (Row, depth)->
		# 	@forwardRemove()
		# 	@backwardRemove()

		# forwardAdd: ()->

		# forwardRemove: ()->

		# backwardAdd: ()->

		# backwardRemove: ()->

		# remove: ()->

	class tableUnitView extends Backbone.View
		tagName: 'tr'
		constructor: ()->
			@structure = @options.structure
			@position = @options.position
			@parent_el = @options.parent_el

			@title = @title() if !@options.isRoot
			@parent = @options.creater ? @options.creater :null
			@render()

			@children()
			@rowspan()

		render: ()->
			@parent_el.append @el
			@el.html('<td>' + @title + '</td>'))

		title: ()->
			position = "[" + @position.join("][") + "]"
			return eval("@structure" + position )

		children: ()->
			if _.first(@position) is (@structure.length - 1)
				@children = []
				return

			for x in 0..(@structure[ _.first(@position) + 1 ].length - 1)
				do (x)->
					view = new tableUnitView(
						structure  : @structure
						position   : [ _.first(@position) + 1, x]
						isRoot     : false
						creater    : @
						parent_el  : $(@el) )
					@children.push view

		rowspan: ()->
			return 0 if !@hasChildren()

			@rowspan = 1
			for x in 1..@structure.length
				do (x)->
					@rowspan = @rowspan * x.length if _.isArray(x)

			$(@el).attr('rowspan', @rowspan)

		resetRowspan: ()->
			@rowspan()
			@parent.resetRowspan() if @parent.hasParent()

		hasParent: ()->
			return !!@parent

		hasChildren: ()->
			return @children.length > 0

		destroy: (title)->
			return null if @title isnt title
			@parent.resetRowspan() if @hasParent()
			@el.remove()
			@remove()


	# class tableCollection extends Backbone.Collection
	# 	model: tableUnitModel

	# class tableUnitModel extends Backbone.Model


	exports