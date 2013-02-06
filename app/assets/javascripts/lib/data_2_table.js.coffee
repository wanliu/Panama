define ['jquery', 'exports'], ($, exports) ->
	class exports.Data2Table
		constructor: (collection) ->
			@collection = collection.collection
			that = @

			$('a.trigger-data-filled').click ()->
				that.trigger_filled()

		trigger_filled: ()->
			@init_inputs()
			@fill_data()

		init_inputs: () ->
			@inputs = $('.js-createdTable :text')

		fill_data: () ->
			Window.inputs = @inputs
			for input in @inputs
				input_class = $(input).attr('class')
				input_vector = input_class.split('-')
				Window.input = input_vector
				Window.collection = @collection
				$(input).val @get_value(input_vector)

		get_value: (input_vector) ->
			type = input_vector.pop()
			for item in @collection
				values = _.values(item)
				before = values.length
				after = _.uniq(input_vector.concat(values)).length
				return item[type] if after is before

	exports