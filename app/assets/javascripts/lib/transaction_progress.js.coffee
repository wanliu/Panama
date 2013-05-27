#交易订单进度条

define ["jquery", "backbone"], ($, Backbone) ->
  class Badge extends Backbone.View
    tagName: "span"
    className: "state-position badge"

    initialize: (options) ->
      _.extend(@, options)

      @$el = $(@el)
      @$el.html(@index + 1)
      @$el.append("<div class='state-title'>#{@name}</div>")
      @$el.css @badge_style()

      if @complete_index >= @index
        @$el.addClass(@class_badge)

    badge_style: () ->
      if @last_state
        {right: "0px"}
      else
        {left: "#{@width * @index}px"}

    render: () ->
      @$el

  class Progress extends Backbone.View
    className: "state-bar bar"

    initialize: (options) ->
      _.extend(@, options)

      @$el = $(@el)
      @load_progress()

    load_progress: () ->
      @$el.width("#{@bar_width}%")
      @$el.addClass(@class_progress)

    render: () ->
      @$el


  class TransactionProgress extends Backbone.View
    stateFlow: [
      {state: "order", class_badge: "badge-info"},
      {state: "waiting_paid", class_badge: "badge-important", class_progress: "bar-info"},
      {state: "waiting_delivery", class_badge: "badge-warning", class_progress: "bar-success"},
      {state: "waiting_sign", class_badge: "badge-inverse", class_progress: "bar-warning"},
      {state: "complete", class_badge: "badge-success", class_progress: "bar-danger"}
    ]

    initialize: (options) ->
      debugger
      @$el = $(@el)
      @state = @options.state
      @localName = @options.localName
      @load_state()

    load_state: () ->
      bar_width = 100 / (@stateFlow.length-1)
      _.each @stateFlow, (info, i) =>
        complete_index = @state_index()
        if complete_index > i
          progress = new Progress( bar_width: bar_width, class_progress: info.class_progress )
          @$el.append(progress.render())

        badge = new Badge(_.extend({
          width: @$el.width() / (@stateFlow.length - 1),
          complete_index: complete_index,
          index: i,
          name: @localName[info.state],
          last_state: @last_status(i+1)
        }, info))
        @$el.append badge.render()


    last_status: (i) ->
      if @stateFlow.length is i then true else false

    state_index: () ->
      for info, i in @stateFlow
        if info.state is @state
          return i

      return -1
