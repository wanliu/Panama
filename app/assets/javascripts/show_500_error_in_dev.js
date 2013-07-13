(function() {
  if ($) {
    $.ajaxSetup({
        error: function(jqXHR, exception) {
          if (jqXHR.status == 500 && $.pnotify) {
            $.pnotify({ title : "WTF!! 有BUG!!",
                        text  : "请检查应用后台, 查看错误信息",
                        type  : "error" })
          }
        }
    })
  }
}).call(this)