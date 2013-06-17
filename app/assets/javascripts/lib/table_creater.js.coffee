#= require jquery
#= require backbone

root = window || @

class root.TableCreater extends Backbone.View
	tagName: 'table'
	className: 'table table-bordered js-createdTable'
	attributes:
		style : 'border-top: none;'
	#schema:
	#	depth: [color, size]    #维度
	#	structure: [[red, blue, white], [M, ML, XL, XXL], ....]  #初始表结构对象
	#	data: [price, quantity]  #数据字段

	initialize: (target, @options) ->
		_.extend(@, @options)
		@render(target)
		@parseTable()

	render: (el) ->
		$(@el).html('<tbody></tbody>')
		el.after(@el)

	parseTable: () ->
		@tableView = new TableUnitView(
			schema     : @schema
			position   : [-1, 0]
			isRoot     : true
			creater    : null
			parent_el  : @$('tbody') )

	checkRow: () ->
		@tableView.checkRow()

class TableUnitView extends Backbone.View
	tagName: 'tr'
	storeField: 'product[prices]'

	initialize: () ->
		_.extend(@, @options)
		@structure = @schema.structure

		@initTitle() if !@options.isRoot
		@parent = if @options.creater then @options.creater else null
		@render()

		@initRowspan()
		@initChildren()

	render: () ->
		if @hasChildren()  # render the no-leaf node
			$(@el).html('<td class="title">' + (if @title then @title else '') + '</td>')
		else  # render leaf node
			counter = counterFun()

			arr = @getNameField()
			to_filled = ''
			html_front = for item in arr
				name = @schema['depth'] if @schema['depth']
				name = name[_.first(item['position'])]
				to_filled = "#{item.value}-" + to_filled
				"<input type='hidden' name='#{@storeField}[#{counter}][#{name}]' value=#{item.value} >"

			html = for data in @schema['data']
				"<td>#{data.title}: &nbsp;&nbsp;&nbsp;&nbsp;<input class='#{to_filled + data.value}' name=#{@storeField}[#{counter}][#{data.value}]  type='text'></td>"

			$(@el).html('<td class="title">' + (if @title then @title else '') + '</td>' + html_front + html)

		# load no root node to DOM tree
		if @hasParent()
			@parent_el.after(@el)
			return @

		# load the root node to DOM tree
		$(@el).css('display', 'none')
		@parent_el.append(@el)
		@

	initTitle: () ->
		that = @
		position = "[" + @position.join("][") + "]"
		@title = eval("that.structure#{position}" )

	initChildren: () ->
		return (@children = []) unless @hasChildren()

		parent_el = $(@el)
		@children = @children || []

		for x in [0...@structure[ _.first(@position) + 1 ].length]
			view = new TableUnitView(
				structure  : @structure
				position   : [ _.first(@position) + 1, x]
				isRoot     : false
				schema     : @schema
				creater    : @
				parent_el  : parent_el
			)
			@.children.push view
			parent_el = $(view.lastChild().el)

		#在table被渲染完毕后，通过click绑定/触发，调用table的数据填充程序
		@fillTableData() unless @hasParent()

	initRowspan: () ->
		return if !@hasChildren() or !@hasParent()

		@rowspan = 1
		start = _.first(@position) + 1
		for x in [start..@structure.length - 1]
			@rowspan = @rowspan * @structure[x].length if _.isArray(@structure[x])

		if start <= @structure.length - 2
			for x in [start..@structure.length - 2]
				@rowspan += @structure[x].length if _.isArray(@structure[x])

		@$('td').attr('rowspan', @rowspan + 1)

	resetRowspan: () ->
		@initRowspan()
		@parent.resetRowspan() if @hasParent()

	hasParent: () ->
		!!@parent

	hasChildren: () ->
		_.first(@position) isnt (@structure.length - 1)

	lastChild: () ->
		return @ unless @hasChildren()
		_.last(@children).lastChild()

	checkRow: () ->
		return unless @hasChildren()

		@increceCheck()
		@reduceCheck()

		child.checkRow() for child in @children

	destroy: () ->
		child.destroy() for child in @children if @hasChildren()

		$(@el).remove()
		@parent.resetRowspan() if @hasParent()
		@remove()

	increceCheck: () ->
		for title in @structure[_.first(@position) + 1]
			unless _.contains( _.map(@children, (child) -> child['title'] ), title)
				@addChild(title)

	reduceCheck: () ->
		for title in _.map( @children, (child) -> child['title'] )
			unless _.contains(@structure[_.first(@position) + 1], title)
				@removeChild(title)

	addChild: (title) ->
		index = _.indexOf(@structure[_.first(@position) + 1], title)

		parent_el = if index is 0
			$(@el)
		else
			front_title = @structure[_.first(@position) + 1][index - 1]
			front_view = _.find(@children, (child) -> child.title is front_title)
			$(front_view.lastChild().el)

		view = new TableUnitView(
			structure  : @structure
			position   : [ _.first(@position) + 1, index]
			isRoot     : false
			schema     : @schema
			creater    : @
			parent_el  : parent_el
		)
		@children.splice(index, 0, view)
		@resetRowspan()

	removeChild: (title) ->
		if ( badLuckyGuy = _.find(@children, (child) -> child.title is title) )
			@children.splice(_.indexOf(@children, badLuckyGuy), 1)
			badLuckyGuy.destroy()

	fillTableData: () ->
		$('a.trigger-data-filled').data('draw_complited', 'yes')
		$('a.trigger-data-filled').click()

	getNameField: ()->
		node = @
		arr = []
		while node.hasParent()
			arr.push
				position : node.position
				value    : node.title

			node = node.parent
		arr


counterFun = (() ->
	counter = 1
	innerCounter = ()-> counter++
	innerCounter )()


