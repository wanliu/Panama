#= require signals
#= require hasher
#= require crossroads
root = window || @

root.Ajaxify = {
	addRoute: (pattern, handle) ->
		crossroads.addRoute pattern, handle

	start: () ->
		crossroads.routed.add console.log, console #log all routes
		# hasher.prependHash = '!';
		hasher.initialized.add @parseHash # parse initial hash
		hasher.changed.add @parseHash  # parse hash changes
		hasher.init()  # start listening for history change

	parseHash: (newHash, oldHash) ->
		crossroads.parse(newHash)

	go: (hash) ->
		hasher.setHash(hash)
}


