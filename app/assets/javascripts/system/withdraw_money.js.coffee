
root = (window || @)

class root.WithDrawMoneyView extends Backbone.View
  events: {
    "click a.succeed" : "succeed"
    "click a.failer" : "failer"
  }

  initialize: () ->

  succeed: (event) ->    
    @fetch $(event.currentTarget).attr("href")
    false

  failer: (event) ->
    @fetch $(event.currentTarget).attr("href")
    false

  fetch: (url) ->
    $.ajax(
      url: url, 
      type: 'POST',
      success: () ->
        pnotify(text: "操作成功")
        window.location.reload()

      error: (data) ->
        ms = JSON.parse(data.responseText)
        pnotify(text: ms.join("<br />"), type: "error")
    )

