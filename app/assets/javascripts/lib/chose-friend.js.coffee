require ["jquery", "hogan"], ($, hogan) ->

  class ChoseFriendInput
    input: $("<input type='text' />"),
    constructor: (opts) ->

    render: () ->
      @el


  class ChoseFriend
    defulat_opts: {
      engine: Hogan,
      template: "",
      value: "name",
      data: [],
      el: null
    }

    constructor: (opts) ->
      @set_options(opts)
      @input = new ChoseFriendInput()
      @defulat_opts.el.html(@input.render())

    set_options: (opts) ->
      $.extend(@defulat_opts, opts)



