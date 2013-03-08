# author: huxinghai
# describe: 邀请雇员

define(["jquery"], ($) ->

    class EmployeeInvite
        default_params: {
            form_el: null
            url: null
            success_callback: (data, xhr) ->
            error_callback: (data, xhr) ->
        }

        constructor: (options) ->
            _.extend(@default_params, options)
            @bind_submit()

        invite: () ->
            input = @default_params.form_el.find("input[name=login]")
            input.attr("disabled", true)

            $.ajax({
                url: @default_params.url,
                data: {login: input.val()},
                type: "POST",
                success: @default_params.success_callback,
                error: @default_params.error_callback,
                complete : () ->
                    input.attr("disabled", false)
            })

            return false

        bind_submit: ()->
            @default_params.form_el.submit(_.bind(@invite, @))

    EmployeeInvite
)