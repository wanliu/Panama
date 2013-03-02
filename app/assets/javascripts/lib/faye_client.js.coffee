
define(["faye"], () ->
	realtime = new Faye.Client('/realtime');
	realtime
)