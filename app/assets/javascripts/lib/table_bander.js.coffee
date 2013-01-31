define ['jquery', 'backbone', 'lib/table_creater', 'exports'], ($, Backbone, TblCreater, exports)->
	class exports.TableBander
		constructor: (options) ->
			@els = options.els
			@data = options.fields
			@depth = []
			@structure = []

			@schema =
				depth     : @depth
				structure : @structure
				data      : @data

			@loadEl = _.last @els
			@initStructure()

		initStructure: () ->
			that = @
			deleEvents = (el) ->
				el.delegate ':checkbox', 'click', () ->
						that.countChecked()

			deleEvents el for el in @els

		countChecked: () ->
			that = @
			index = 0
			for el in @els
				do (el) ->
					collection = el.find ':checkbox'
					selecteds = _.filter collection, (item) -> $(item).attr('checked') is "checked"
					that.structure[index] = _.map selecteds, (item) -> $(item).val()
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
				@table = new TblCreater.TableCreater @loadEl, @schema
			else
				@table.checkRow()

	exports