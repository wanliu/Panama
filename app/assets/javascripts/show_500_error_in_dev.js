(function() {
  if ($) {
    $.ajaxSetup({
        error: function(jqXHR, exception) {
          if (jqXHR.status == 500) {
            error = jqXHR.error()

            pnotify({
              title : error.statusText,
              text  : error.responseText,
              type  : "error"})
          }
        }
    })
  }
}).call(this)