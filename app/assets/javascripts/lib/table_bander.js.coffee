#= require jquery
#= require backbone
#= require lib/table_creater

root = window || @

class root.TableBander
	constructor: (options) ->
		@els = options.els
		@data = options.fields
		@depth = options.depth
		@structure = []

		@schema =
			depth     : @depth
			structure : @structure
			data      : @data

		@loadEl = _.last(@els)
		@init()

	init: () ->
		@initStructure()
		@initEls()
		@countChecked()

	initStructure: () ->
		that = @
		deleEvents = (el) ->
			el.delegate ':checkbox', 'click', () ->
					that.countChecked()

		deleEvents el for el in @els

	countChecked: () ->
		index = 0
		for el in @els
			collection = el.find ':checkbox'
			selecteds = _.filter collection, (item) -> $(item).attr('checked') is "checked"
			@structure[index] = _.map(selecteds, (item) -> $(item).val())
			index++

		@checkRow()

	checkRow: () ->
		ifEmpty = _.some @structure, (item)-> _.isEmpty(item)
		if ifEmpty
			@table.remove() if @table
			@drawed = false
			return

		return if _.isEmpty( _.last(@structure) ) and not @drawed

		if not @drawed
			@drawed = true
			@table = new TableCreater(@loadEl, schema: @schema)
		else
			@table.checkRow()

	initEls: () ->
		@editableEl el for el in @els

	editableEl: (el) ->
		@editableLable label for label in el.find('label')

	editableLable: (lable) ->
		that = @
		nameNode = $(lable).find('.name')
		nameNode.on('dblclick', $.proxy(that.editLable, that))

	editLable: (event) ->
		oldHtml = $(event.srcElement).html()
		input = $("<input class='eidtName' type='text' style='width:80px; height:13px;' value=" + oldHtml + ">")
		$(event.srcElement).hide()
		lable = $(event.srcElement).parents('label')
		lable.append(input)

		input.change () =>
			value = input.val()
			$(lable.find(':hidden')).val(value)
			$(lable.find(':checkbox')).val(value)
			$(lable.find('span.name')).html(value)
			input.remove()
			$(event.srcElement).show()
			@countChecked()

