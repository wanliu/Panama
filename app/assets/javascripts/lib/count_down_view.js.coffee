root = (window || @)
class root.CountdownView

  maxTime: 5

  constructor: (el, url) ->
    @el = el
    @url = url
    @setClock(@maxTime)
    interval_id = setInterval(() =>
      @setClock(--@maxTime)
      
      if(@maxTime <= 0)
        clearInterval(interval_id) 
        window.location.href = @url  

    , 1000)

  setClock: (tm) ->
    $(".clock", @el).html(tm)  