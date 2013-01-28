define ['jquery', 'backbone', 'exports'], ($, Backbone, exports)->
	class exports.tableCreater extends Backbone.View
		tagName: 'table'
		className: 'table table-bordered'
		#schema:
		#	depth: [color, size]    #维度
		#	structure: [[red, blue, white], [M, ML, XL, XXL], ....]  #初始表结构对象
		#	data: [price, quantity]  #数据字段
		initialize: (el, schema)->
			@render(el)
			@schema = schema
			@parseTable()

		render: (el)->
			$(@el).html('<tbody></tbody>')
			el.append(@el)

		parseTable: ()->
			Window.tableView = @tableView = new tableUnitView(
				schema     : @schema
				position   : [-1, 0]
				isRoot     : true
				creater    : null
				parent_el  : @$('tbody') )

		checkRow: ()->
			@tableView.checkRow()

	class tableUnitView extends Backbone.View
		tagName: 'tr'
		initialize: ()->
			@structure = @options.schema.structure
			@schema = @options.schema
			@position = @options.position
			@parent_el = @options.parent_el

			@initTitle() if !@options.isRoot
			@parent = if @options.creater then @options.creater else null
			@render()

			@initChildren()
			@initRowspan()

		render: ()->
			if @hasChildren()
				$(@el).html('<td class="title">' + (if @title then @title else '') + '</td>')
			else
				html = for data in @schema['data']
					do (data)->
						"<td>#{data}: <input type='text'></td>"

				$(@el).html('<td class="title">' + (if @title then @title else '') + '</td>' + html)

			if @hasParent() and @parent.parent
				@parent_el.after(@el)
				return @

			if @hasParent() and !@parent.parent
				@parent_el.append(@el)
				@

		initTitle: ()->
			that = @
			position = "[" + @position.join("][") + "]"
			@title = eval("that.structure#{position}" )

		initChildren: ()->
			return (@children = []) if not @hasChildren()

			that = @
			parent_el = if @hasParent() then $(@el) else $(@parent_el)
			@children = @children || []

			for x in [0...@structure[ _.first(@position) + 1 ].length]
				do (x)->
					view = new tableUnitView(
						structure  : that.structure
						position   : [ _.first(that.position) + 1, x]
						isRoot     : false
						schema     : that.schema
						creater    : that
						parent_el  : parent_el
					)
					that.children.push view
					parent_el = if that.hasParent() then $(view.render().el) else that.parent_el

		initRowspan: ()->
			return if !@hasChildren()
			that = @
			@rowspan = 1
			start = _.first(@position) + 1
			for x in [start..that.structure.length - 1]
				do (x)->
					that.rowspan = that.rowspan * that.structure[x].length if _.isArray(that.structure[x])

			@$('td').attr('rowspan', @rowspan + 1)

		resetRowspan: ()->
			@initRowspan()
			@parent.resetRowspan() if @hasParent()

		hasParent: ()->
			return !!@parent

		hasChildren: ()->
			return _.first(@position) isnt (@structure.length - 1)

		checkRow: ()->
			return if not @hasChildren()

			@increceCheck()
			@reduceCheck()

			for child in @children
				do (child)->
					child.checkRow()

		destroy: ()->
			# return null if @title isnt title
			if @hasChildren()
				for child in @children
					do (child)->
						child.destroy()

			$(@el).remove()
			@parent.resetRowspan() if @hasParent()
			@remove()

		increceCheck: ()->
			for title in @structure[_.first(@position) + 1]
				if not _.contains( _.map(@children, (child)-> child['title'] ), title)
					@addChild(title)

		reduceCheck: ()->
			for title in _.map( @children, (child)-> child['title'] )
				if not _.contains(@structure[_.first(@position) + 1], title)
					@removeChild(title)

		addChild: (title)->
			index = _.indexOf(@structure[_.first(@position) + 1], title)

			parent_el = if index is 0
				$(@el)
			else
				front_title = @structure[_.first(@position) + 1][index - 1]
				front_view = _.find(@children, (child)-> child.title is front_title)
				$(front_view.el)

			view = new tableUnitView(
				structure  : @structure
				position   : [ _.first(@position) + 1, index]
				isRoot     : false
				schema     : @schema
				creater    : @
				parent_el  : parent_el
			)
			@children.splice(index, 0, view)
			@resetRowspan()

		createView: ()->

		removeChild: (title)->
			if ( badLuckyGuy = _.find(@children, (child)-> child.title is title) )
				@children.splice(_.indexOf(@children, badLuckyGuy), 1)
				badLuckyGuy.destroy()

	exports