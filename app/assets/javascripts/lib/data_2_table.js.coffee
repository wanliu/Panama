define ['jquery', 'exports'], ($, exports) ->
	class exports.Data2Table
		constructor: (collection) ->
			@collection = collection.collection

			$('a.trigger-data-filled').click () =>
				@trigger_filled()

		trigger_filled: ()->
			@init_inputs()
			@fill_data()

		init_inputs: () ->
			@inputs = $('.js-createdTable :text')

		fill_data: () ->
			for input in @inputs
				input_class = $(input).attr('class')
				input_vector = input_class.split('-')
				$(input).val @get_value(input_vector)

		get_value: (input_vector) ->
			type = input_vector.pop()
			for item in @collection
				values = _.values(item)
				before = values.length
				after = _.uniq(input_vector.concat(values)).length
				return item[type] if after is before

	exports