#bubbing 提醒
define ["jquery", "lib/jquery.pnotify"], ($) ->

  (options) ->

    default_options = {
      stack_topleft: {
        "dir1": "down",
        "dir2": "right",
        "push": "top"
      },
      stack_bottomleft: {
        "dir1": "right",
        "dir2": "up",
        "push": "top"
      },
      stack_custom: {
        "dir1": "right",
        "dir2": "down"
      },
      stack_custom2: {
        "dir1": "left",
        "dir2": "up",
        "push": "top"
      },
      stack_bar_top: {
        "dir1": "down",
        "dir2": "right",
        "push": "top",
        "spacing1": 0,
        "spacing2": 0
      },
      stack_bar_bottom: {
        "dir1": "up",
        "dir2": "right",
        "spacing1": 0,
        "spacing2": 0
      },
      stack_bottomright: {
        "dir1": "up",
        "dir2": "left",
        "firstpos1": 25,
        "firstpos2": 25
      },
      stack_topright: {
        "dir1": "down",
        "dir2": "left",
        "push": "top"
      }
    }

    if options.hasOwnProperty("stack")
      options["stack"] = default_options[options.stack]

    $.pnotify(options)


