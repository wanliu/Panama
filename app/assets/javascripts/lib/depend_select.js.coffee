define ['jquery','backbone'], ($,Backbone) ->
	
	class DependSelectView extends Backbone.View 
		events: {
			# 'click .spinner-up' : 'spinnerUp' 
		},

		initialize: (options) ->
			_.extend(@,options)
			debugger
			
			ss = ""