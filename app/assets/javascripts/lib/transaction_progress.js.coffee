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
    state_type: "transaction",

    stateFlow: {
      transaction: [
        {
          state: "order",
          class_badge: "badge-info",
          class_progress: "bar-info",
          to: "waiting_paid"
        },
        {
          state: "waiting_paid",
          class_badge: "badge-inverse",
          class_progress: "bar-warning",
          to: "waiting_delivery"
        },
        {
          state: "waiting_delivery",
          class_badge: "badge-warning",
          class_progress: "bar-danger",
          to: "waiting_sign"
        },
        {
          state: "waiting_sign",
          class_badge: "badge-important",
          class_progress: "bar-success"
          to: "complete"
        },
        {
          state: "complete",
          class_badge: "badge-success"
        }
      ],
      returned: [
        {
          state: "apply_refund",
          class_badge: "badge-info",
          class_progress: "bar-danger"},
        {
          state: "waiting_delivery",
          class_badge: "badge-important",
          class_progress: "bar-warning"
        },
        {
          state: "waiting_sign",
          class_badge: "badge-warning",
          class_progress: "bar-success"
        },
        {
          state: "complete",
          class_badge: "badge-success"
        }
      ]
    }

    initialize: (options) ->
      @$el = $(@el)
      @state = @options.state
      if @options.state_type?
        @state_type = @options.state_type

      @localName = @options.localName

      @states = @stateFlow[@state_type]
      @load_state()

    load_state: () ->
      bar_width = 100 / (@states.length-1)
      _.each @states, (info, i) =>
        complete_index = @state_index()
        if complete_index > i
          progress = new Progress( bar_width: bar_width, class_progress: info.class_progress )
          @$el.append(progress.render())

        badge = new Badge(_.extend({
          width: @$el.width() / (@states.length - 1),
          complete_index: complete_index,
          index: i,
          name: @localName[info.state],
          last_state: @last_status(i+1)
        }, info))
        @$el.append badge.render()


    last_status: (i) ->
      if @states.length is i then true else false

    state_index: () ->
      for info, i in @states
        if info.state is @state
          return i

      return -1
