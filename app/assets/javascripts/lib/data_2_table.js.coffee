#= require 'jquery'

root = window || @

class root.Data2Table
	constructor: (collection) ->
		@collection = collection.collection
		#两种触发条件。触发类型取决于本js类与form中table的载入顺序
		#①按键触发
		@detect_if_button_clicked()
		#②检测触发
		@detect_if_draw_complited()
		@trigger_filled()

	detect_if_button_clicked: () ->
		$('a.trigger-data-filled').click () =>
			@trigger_filled()

	detect_if_draw_complited: () ->
		if $('a.trigger-data-filled').data('draw_complited') is 'yes'
			@trigger_filled()

	trigger_filled: ()->
		@init_inputs()
		@fill_data()

	init_inputs: () ->
		@inputs = $('.js-createdTable :text')

	fill_data: () ->
		for input in @inputs
			input_class = $(input).attr('class')
			input_id = input_class.split('-')
			$(input).val @get_value(input_id)

	get_value: (input_id) ->
		type = input_id.pop()
		for item in @collection
			values = _.values(item)
			before = values.length
			after = _.uniq(input_id.concat(values)).length
			return item[type] if after is before

