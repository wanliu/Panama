root = window || @
class root.BackDropView extends Backbone.View
  events: {
  	"click" : "_close"
  }
  initialize: () ->
    @$backdrop = $("body>.model-popup-backdrop")
    if @$backdrop.length <= 0
      @$backdrop = $("<div class='model-popup-backdrop out' />").appendTo("body")

  show: () ->
    @$backdrop.removeClass("out").addClass("in")

  hide: () ->
    @$backdrop.removeClass("in").addClass("out")

  close: () ->

  _close: () ->
  	@hide()
  	@close()