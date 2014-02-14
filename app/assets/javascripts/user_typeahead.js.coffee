# author: huxinghai
# describe: 搜索用户

#= require lib/hogan

root = window || @

class UserTypeahead

  constructor: (input_el) ->
    @input_el = input_el
    @bind_typeahead()

  bind_typeahead: () ->
    @input_el.typeahead(
      name: "users",
      remote: "/search/users?q=%QUERY&limit=10",
      template: [
        '<span class="repo-avatar"><img class="img-rounded user-avatar" src="{{icon_url}}" />{{login}}</span>',
        '<span class="repo-email">{{login}}@test.com</span>'
      ].join(''),
      engine: Hogan
    )

root.UserTypeahead = UserTypeahead
