
root = (window || @)

class root.UpdatePasswordView extends Backbone.View
  
  initialize: () ->
    pm.bind "update_password_notify", (data) =>
      pnotify(data)

      @$el.modal("hide") if data.type == "success"

