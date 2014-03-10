
class window.OrderExport extends Backbone.View
  ifr_el: "<iframe />"

  opts: {}

  events: {
    "click a.print" : 'load_print'
    'click a.download' : 'load_download'
  }

  initialize: (options) ->
    _.extend(@, options)

    @$display_el = @$(".print_display")


  load_print: () ->
    ifr_name = "ifr_order_print_#{@order_id}"
    iframe = @$display_el.find(">iframe")
    if iframe.length > 0
      @print(ifr_name)
    else
      ifra = $(@ifr_el).attr("name", ifr_name)
      ifra.attr("id", ifr_name)
      ifra.attr("src", @url_print)
      if $.browser.msie       
        ifra.load () =>
          @print(ifr_name)        
        @$display_el.html(ifra)
      else
        @$display_el.html(ifra)      
        @print(ifr_name)              

  print: (ifr_ame) ->
    iframe = window.frames[ifr_ame]
    if _.isEmpty(iframe)
      iframe = document.getElementById(ifr_ame)
      iframe.focus()
      iframe.contentWindow.print()
    else
      iframe.focus()
      iframe.print()

  load_download: () ->
    window.location.href = @url_download

