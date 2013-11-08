
root = window || @

class AddressesView extends Backbone.View
	initialize: (options) ->
		_.extend(@, options)
		@$el = $(@el)

	events:
		"click #new_address .save-button" : "new_address"
		"click .address .edit-button"     : "update_address"

	new_address: (event) ->
		@$el.find("form#new_address_form").submit()

	update_address: (event) ->
		@$el.find("form#edit_address_form").submit()


class AddressEditView extends Backbone.View
	events:
		"click .edit-button" : "update_address"

	update_address: (event) ->
		$.ajax(
			type: "POST",
			dataType: "JSON",
			data: @$("form").serialize(),
			url: @$("form").attr("action"),
			success: (data) =>
				$(".address_input").val(data.address)
				# @$("#shop_auth_address_id").val(data.id)
				@$el.modal('hide')
				@$("#edit_address").modal('hide')
				pnotify({text: "修改地址成功！"})
			error: (xhr, status) =>
				@$("form").html(xhr.responseText)
				pnotify({text: "请确定完善地址信息！"})
		)
		false


root.AddressesView = AddressesView
root.AddressEditView = AddressEditView
