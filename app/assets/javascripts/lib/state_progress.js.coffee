#交易订单进度条

class Badge extends Backbone.View
  tagName: "span"
  className: "state-position badge"
  initialize: (options) ->
    _.extend(@, options)

    @$el = $(@el)
    @$el.html(@index + 1)
    @$el.append("<div class='state-title'>#{@name}</div>")
    @$el.css @badge_left

    if @complete_index > @index
      @$el.addClass(@class_badge)

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

class StateProgress extends Backbone.View
  state_type: "transaction",
  badge_width: 15,
  stateFlow: {
    transaction:{
      order: {
        class_badge: "badge-info",
        to: "waiting_paid"
      },
      waiting_paid: {
        class_badge: "badge-inverse",
        class_progress: "bar-info",
        to: "waiting_delivery"
      },
      waiting_delivery: {
        class_badge: "badge-warning",
        class_progress: "bar-warning",
        to: "waiting_sign"
      },
      delivery_failure:{
        class_badge: "badge-important",
        class_progress: "bar-danger",
        to: "refund"
      },
      waiting_sign: {
        class_badge: "badge-important",
        class_progress: "bar-danger",
        to: "complete"
      },
      complete: {
        class_badge: "badge-success",
        class_progress: "bar-success"
      },
      close: {
        class_badge: "badge-success",
        class_progress: "bar-success"
      },
      refund:{
        class_badge: "badge-info",
        class_progress: "bar-info"
      },
      waiting_refund: {
        class_badge: "badge-success",
        class_progress: "bar-success"
        to: "refund"
      },
      waiting_transfer: {
        class_badge: "badge-inverse",
        class_progress: "bar-info",
        to: "waiting_audit"
      },
      waiting_audit: {
        class_badge: "badge-info",
        class_progress: "bar-info",
        to: "waiting_delivery"
      },
      waiting_audit_failure: {
        class_badge: "badge-success",
        class_progress: "bar-success"
        to: "waiting_audit"
      }
    },

    returned: {
      apply_refund: {
        class_badge: "badge-info",
        to: "waiting_delivery"
      },
      apply_failure: {
        class_badge: "badge-warning",
        class_progress: "bar-warning",
      },
      apply_expired: {
        class_badge: "badge-inverse",
        class_progress: "bar-info"
      },
      waiting_delivery: {
        class_badge: "badge-important",
        class_progress: "bar-danger",
        to: "waiting_sign"
      },
      waiting_sign: {
        class_badge: "badge-warning",
        class_progress: "bar-warning",
        to: "complete"
      },
      complete: {
        class_progress: "bar-success",
        class_badge: "badge-success"
      },
      close: {
        class_progress: "bar-success",
        class_badge: "badge-success"
      }
    }
  }

  initialize: (options) ->
    @$el = $(@el)

    if @options.state_type?
      @state_type = @options.state_type

    @states = []
    @localName = @options.localName
    @complete_states = @options.complete_states
    @define_states = @stateFlow[@state_type]
    @load_state_flow()

    @load_state()

  load_state: () ->
    complete_index = @complete_states.length
    _.each @states, (info, i) =>
      if i > 0 && complete_index > i
        @render_progress(info.class_progress)

      @render_badge(complete_index, i, info)

  load_state_flow: () ->
    _.each @complete_states, (item) =>
      @added_states(item.state)

    item = @last_complete_state()
    if item?
      @load_define_state(item.state)

  load_define_state: (state) ->
    info = @get_state_flow(state)
    if info && info.to?
      @added_states info.to
      @load_define_state(info.to)

  added_states: (state) ->
    info = @get_state_flow(state)
    if info
      @states.push info
    else
      console.error("没有设置#{state}")

  render_progress: (class_progress) ->
    progress = new Progress( bar_width: @bar_width(), class_progress: class_progress )
    @$el.append(progress.render())

  render_badge: (complete_index, index, info) ->
    badge = new Badge(_.extend({
      complete_index: complete_index,
      index: index,
      name: @localName[info.state],
      badge_left: @badge_left(index)
    }, info))
    @$el.append badge.render()

  last_complete_state: () ->
    _.last @complete_states

  get_state_flow: (state) ->
    info = @define_states[state]
    if info?
      _.extend(info, {state: state})
    else
      false

  badge_left: (index) ->
    {left: "#{(100 / (@states.length-1)) * index}%"}

  bar_width: () ->
    100 / (@states.length - 1)

  progress_width: () ->
    @$el.width() / (@states.length - 1)

window.StateProgress = StateProgress