#= require lib/state-machine

exports = window || @

_.mixin
	capitalize: (string) ->
		string.charAt(0).toUpperCase() + string.substring(1).toLowerCase()

	camel: (string) ->
		string.replace /(\_[a-z])/g, ($1) ->
			$1.toUpperCase().replace('_','')

class AbstructStateView extends Backbone.View

	initialize: (@options = {}) ->
		super
		# @$el = $(@el)
		@initial = @options['initial'] || @initial
		@error = @options['error'] || @stateError
		@fsm = StateMachine.create @gatherConfiguration()


	gatherConfiguration: () ->
		configure = @states
		configure['initial'] = @initial
		configure['target'] = @

		callbacks = configure['callbacks'] || {}

		addToCallback = (name, func) ->
			callbacks[name] = func


		for event in configure.events
			# before, after

			@eventMethods event, addToCallback
			@stateMethods event, addToCallback

		configure['callbacks'] = callbacks
		configure

	eventMethods: (event, handle) ->
		@cbMethods(event.name, ['before', 'after'], handle)

	stateMethods: (event, handle) ->
		for state in _([event.from, event.to]).flatten()
			@cbMethods(state, ['enter', 'leave'], handle)

	cbMethods: (name, set, handle) ->
		for prefix in set
			attribute = "on#{prefix}#{name}"
			func = "#{prefix}#{_(_(name).capitalize()).camel()}"
			if _.isFunction(@[func])
				handle.call @, attribute, @[func]

	stateError: (eventName, from, to, args, errorCode, errorMessage) ->
	    msg =  'event ' + eventName + ' was naughty :- ' + errorMessage;
	    console.log msg
	    msg

class StateView extends AbstructStateView

exports.AbstructStateView = AbstructStateView
exports.StateView = StateView
exports