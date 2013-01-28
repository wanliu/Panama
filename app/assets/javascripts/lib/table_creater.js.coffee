define ['jquery', 'backbone', 'exports'], ($, Backbone, exports)->
	class exports.tableCreater extends Backbone.View
		tagName: 'table'
		className: 'table table-striped'
		#schema:
		#	depth: [color, size]    #维度
		#	structure: [[red, blue, white], [M, ML, XL, XXL], ....]  #初始表结构对象
		#	data: [price, quantity]  #数据字段
		initialize: (el, schema)->
			@render(el)
			@schema = schema
			@structure = @schema.structure
			@parseTable()

		render: (el)->
			# @el = $("<table class=''><tbody></tbody></table>")
			$(@el).html('<tbody></tbody>')
			el.append(@el)

		parseTable: ()->
			@tableView = new tableUnitView(
				structure  : @structure
				position   : [-1, 0]
				isRoot     : true
				el         : @$('tbody') )

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
		# tagName: 'tr'
		initialize: ()->
			@structure = @options.structure
			@position = @options.position
			@parent_el = @options.parent_el
			debugger
			@initTitle() if !@options.isRoot
			@parent = if @options.creater then @options.creater else null
			@render()

			@initChildren()
			# @initRowspan()

		render: ()->
			if @hasParent()
				$(@el).html('<td class="title">' + (if @title then @title else '') + '</td>')
				# @parent_el.append @el

		initTitle: ()->
			that = @
			position = "[" + @position.join("][") + "]"
			@title = eval("that.structure#{position}" )

		initChildren: ()->
			return (@children = []) if _.first(@position) is (@structure.length - 1)

			that = @
			@children = @children || []

			children_load_el = if @hasParent()
				children_el = $('<td class="children"></td>')
				$(@el).append children_el
				children_el
			else
				$(@el)

			for x in [0...@structure[ _.first(@position) + 1 ].length]
				do (x)->
					child_el = $("<tr></tr>")
					children_load_el.append( child_el )
					view = new tableUnitView(
						structure  : that.structure
						position   : [ _.first(that.position) + 1, x]
						isRoot     : false
						creater    : that
						el         : child_el )
					that.children.push view

		# initRowspan: ()->
		# 	return 0 if !@hasChildren()
		# 	that = @
		# 	@rowspan = 1
		# 	start = _.first(@position) + 1
		# 	for x in [start...that.structure.length - 1]
		# 		do (x)->
		# 			that.rowspan = that.rowspan * that.structure[x].length if _.isArray that.structure[x]

		# 	$(@el).attr('rowspan', @rowspan)

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