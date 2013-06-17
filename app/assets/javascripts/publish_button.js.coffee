#= require jquery
#= require backbone
#= require create_active

class PublishButton extends Backbone.View

	events:
		"click .create_active": "createActive"
		"click .create_buy"   : "createBuy"


	createActive: (event) ->
		@active ||= new CreateActive el: $('.active_dialog')
		@active.show()


	createBuy: (event) ->
		console.log event
