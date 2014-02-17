# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require jquery
#= require jquery-ui
#= require backbone
#= require lib/dnd


root = window || @

class Category extends Backbone.Model
	

class AbstractRow extends DNDView

	getChildren: () ->
		results = []
		indent = parseInt(@model.get("indent")) || 1
		for tr in @$("~ tr")
			tr_indent = parseInt($(tr).attr('indent')) || 1
			if (tr_indent > indent)
				results.push tr
			else
				break
		results


class CategoryRow extends AbstractRow
	form: "form"

	events:
		"click .category"   : "toggleChildren"
		"click .add_child"  : "newCategoryEditor"
		"click .delete"     : "removeCategory"
		"click .edit"		: "editCategoryEditor"
		"click .save"       : "createCategory"
		"click .cancel"     : "cancelCategory"
		"click .update"		: "updateCategory"
		"ajax:before form"  : "prependForm"
		"ajax:success form" : "categoryCreated"

	initialize: (@options) ->
		@$form = @$(@form)

	render: (state, id = null)->
		url = @state_url(state, id)
		data = {
			ajaxify : true
		}

		data['parent_id'] = @model.id if @model && @model.id?

		html = ""
		$.ajax url: url, async: false , data: data, success: (data) ->
			html = data
		html

	state_url: (state, id = null) ->
		prefix = location.pathname.split("/")
		switch state
			when "new"
				prefix.push(state)
				prefix.join("/")
			when "show", "destroy"
				prefix.push(id)
				prefix.join("/")
			else
				prefix.push(id, state)
				prefix.join("/")

	createCategory: (event) ->
		@$form.submit()

	categoryCreated: (xhr, data, status) ->
		$(@el).replaceWith(data);
		$(@el).fadeOut();

	cancelCategory: (event) ->
		$(@el).slideUp();

		$(@el)
			.promise()
			.done () ->
				@remove()
	editCategoryEditor: (event) ->

	toggleChildren: (event) ->
		$toggleBtn = $(@el).find(".category")
		state = $toggleBtn.attr('state') == 'true'

		for tr in @getChildren()
			if (state) then $(tr).slideUp() else $(tr).slideDown()
		state = !state;
		$toggleBtn.attr 'state', state

	updateCategory: (event) ->
		@$form.submit()

	newCategoryEditor: (event) ->
		data = @render 'new'
		$trs = @getChildren()

		target = if $trs.length > 0
			$trs.pop()
		else
			@el

		$(data).insertAfter target
		false

	prependForm: (event) ->
		@$(":input[name=name]").each (i, input) =>
			$input = $(input)
			name = $input.attr('name')
			$form_input = @$form.find(":input[name='category[#{name}]']")
			$form_input.val($input.val())

	removeCategory: (event) ->
		$.post @state_url('destroy', @model.get("id")), {_method : 'delete'}, () =>
			trs = @getChildren()
			trs.unshift(@el)
			for tr in trs
				$(tr).slideUp()

				$(tr)
					.promise()
					.done () ->
						@remove()
		false


root.CategoryRow = CategoryRow
root.CategoryModel = Category
root.AbstractRow  = AbstractRow
