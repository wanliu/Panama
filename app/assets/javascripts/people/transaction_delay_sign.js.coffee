# 交易收货延时
#= require lib/notify

class TransactionDelaySignView extends Backbone.View
	events:
		"click .delay-sign-event" : "delaySign"

	initialize: (options) ->
		_.extend(@, options)
		@$el = $(@el)

	delaySign: () ->
		url = "#{@remote_url}/delay_sign"
		$.post(url)
			.success (data, xhr, status) =>
				if data.text == "ok"
					pnotify({
						title: "系统提示",
						text: "申请延长收货时间3天成功!", 
						type: "success"
					})
				else if data.text == "no"
					pnotify({
						title: "系统提示",
						text: "您已经申请延迟收货!", 
						type: "success"
					})
				else
					pnotify({
						title: "系统提示",
						text: "请在到期前3天内申请延时!", 
						type: "error"
					})
				
			.error (xhr, status) =>
				pnotify({
					title: "系统提示",
					text: "系统错误!", 
					type: "error"
				})

window.TransactionDelaySignView = TransactionDelaySignView