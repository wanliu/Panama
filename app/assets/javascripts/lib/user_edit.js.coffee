
root = (window || @)

class UpdatePasswordView extends Backbone.View
  
  initialize: () ->
    pm.bind "update_password_notify", (data) =>
      pnotify(data)

      if data.type == "success"
        @$el.modal("hide")
        window.location.href = '/logout'

class UpdateEmailView extends Backbone.View
  
  initialize: () ->
    pm.bind "update_email_notify", (data) =>      

      if data.type == "success"                
        @update(data)              
        pnotify(text: "修改邮箱地址成功！")
        @$el.modal("hide")
      else
        pnotify(data)

  update: (data) ->
    $.ajax(
      url: "/people/update_email",
      type: 'PUT',
      data: {email: data.email},      
      success: () =>  
        @trigger("update_email", data.email)

      error: (xhr) =>
        try
          ms = JSON.parse(xhr.responseText).join("<br />")
          pnotify(text: ms, type: "error")
        catch error
          pnotify(text: xhr.responseText, type: "error")
    )


class root.UserEditView extends Backbone.View

  initialize: () ->

    new UpdatePasswordView(
      el: @$("#edit_password_dialog")
    )

    email = new UpdateEmailView(
      el: @$("#edit_email_dialog")
    )
    email.bind("update_email", _.bind(@update_email, @))

  update_email: (email) ->
    @$(".email").html(email)

