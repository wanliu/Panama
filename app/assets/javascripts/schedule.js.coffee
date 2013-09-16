#= require jquery

root = window || @

class root.Schedule extends Backbone.View

	initialize: (options) ->
		_.extend(@, options)
		@$el = $(@el)
		@DisplayCalendar()

	events:
		"click button.update_activities" : "updateEvent"

	getData: () ->
		post_data = {
			id: @$el.find(".activity_id").val,
			title: @$el.find(".title").val(),
			description: @$el.find(".description").val(),
			start: @$el.find(".begin_time").val(),
			end: @$el.find(".end_time").val()
		}
		$('#activity').modal('hide')
		return post_data

	updateEvent: (my_event) ->
		debugger
		if  !my_event
			debugger
			my_event = getData()
		datas = JSON.stringify(my_event)
		$.ajax({
			type: "POST",
			contentType: "application/json",
			dataType: "json",
			data: datas ,
			url: "/system/activities/"+ my_event.id + "/modify",
			success: () =>
				pnotify({title: '提醒', text: "活动修改成功!",type: "success"})
				@$("#calendar").fullCalendar('refetchEvents')
			error: () ->
				pnotify({title: '错误', text: "修改发生错误,请稍后再试",type: "error"})
		})


	events: (start, end, callback) -> 
		$.ajax({
			url: '/system/activities/schedule_sort1',
			dataType: 'json',
			data: {
				start: Math.round(start.getTime() / 1000),
				end: Math.round(end.getTime() / 1000)
			},
			success: (data) =>
				events = []
				_.each(data, (d) ->
					use_ful = {
						start: d.start_time,
						end: d.end_time,
						description: d.description,
						id: d.id,
						title: d.title,
						status: d.status
					}
					if d.status == 1               
						$.extend(use_ful, { backgroundColor: 'rgb(115, 115, 199)',textColor: 'white'})
					else
						$.extend(use_ful, { backgroundColor: '#dd4b39',textColor: 'white'})
					events.push(use_ful)
				)
				callback(events)
		})

	eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc) ->
		if  event.status == 1
			pnotify({title: '提醒', text: "该活动已经通过审核,不能进行修改 ~~",type: "error"})
			revertFunc()
		else
			@updateEvent(event)

	eventResize: (event, dayDelta, minuteDelta, revertFunc) ->
		@updateEvent(event)

	eventClick: (event, element) ->
		$('.tooltipevent').remove()
		if  event.status == 1
			pnotify({title: '提醒', text: "该活动已经通过审核,不能进行修改 ~~",type: "error"})
		else
			$(".activity_id").val(event.id)
			$(".title").val(event.title)
			$(".description").val(event.description)
			$(".begin_time").val((event.start).format("yyyy-MM-dd"))
			$(".end_time").val((event.end).format("yyyy-MM-dd"))
			$('#activity').modal()
			$('#calendar').fullCalendar('@updateEvent', event)  

	# eventMouseover: (calEvent,jsEvent) ->
	# 	tooltip = '<div class="tooltipevent">'+ 
	# 		'<span>标题: &nbsp;</span> '+ calEvent.title + '<br/>' + 
	# 		'<span>描述:  &nbsp;</span>'+ calEvent.description + '<br/>' +
	# 		'<span>开始时间: &nbsp;</span>'+ calEvent.start.format("yyyy-MM-dd") + '<br/>' +
	# 		'<span>结束时间: &nbsp;</span>'+ calEvent.end.format("yyyy-MM-dd") +
	# 	  '</div>';
	# 	$("body").append(tooltip)
	# 	$(@).mouseover((e) ->
	# 		$(@).css('z-index', 10000)
	# 		$('.tooltipevent').fadeIn('500')
	# 		$('.tooltipevent').fadeTo('10', 1.9)
	# 	).mousemove( (e) ->
	# 		if  $('.tooltipevent')
	# 			left = $('.tooltipevent').position().left
	# 		if  left > window.screen.availWidth-500
	# 			$('.tooltipevent').css('top', e.pageY + 10)
	# 			$('.tooltipevent').css('left', e.pageX - 300)
	# 		else
	# 			$('.tooltipevent').css('top', e.pageY + 10)
	# 			$('.tooltipevent').css('left', e.pageX + 20)
	# 	) 

	# eventMouseout: (calEvent, jsEvent) ->
	# 	$(@).css('z-index', 8)
	# 	$('.tooltipevent').remove()


	DisplayCalendar: () ->
		date = new Date()
		d = date.getDate()
		m = date.getMonth()
		y = date.getFullYear()
		@$('div[id*=calendar]').fullCalendar({
			header: {
				left: 'prev,next today',
				center: 'title',
				right: 'month,agendaWeek,agendaDay'
			},
			buttonText:{
				prev:     '上翻',
				next:     '下翻',
				prevYear: '去年',
				nextYear: '明年',
				today:    '今天',
				month:    ' 月 ',
				week:     ' 周 ',
				day:      ' 日 '
			},
			monthNames: ['一月','二月', '三月', '四月', '五月', '六月', 
						'七月','八月', '九月', '十月', '十一月', '十二月'],
			dayNames: ['星期日', '星期一', '星期二', '星期三','星期四', '星期五', '星期六'],
			dayNamesShort: ['星期日', '星期一', '星期二', '星期三','星期四', '星期五', '星期六'],
			monthNamesShort: ['一月', '二月', '三月', '四月', '五月', '六月',
							'七月', '八月', '九月', '十月', '十一月', '十二月'],

			titleFormat: {
				month: 'yyyy MMMM',  
				week: "yyyy年 MMM d[ yyyy]日 {'&#8212;'[ MMM] d}日 ",               
				day: 'yyyy年 MMM d日, dddd '                  
			},
			selectable: true,
			editable: true,
			defaultView: 'month',
			height: 500,
			slotMinutes: 30,
			timeFormat: 'h:mm t{ - h:mm t} ',
			dragOpacity: "0.5",
			events: @events,
			eventDrop: @eventDrop,
			eventResize: @eventResize,
			eventClick: @eventClick,
			eventMouseover: @eventMouseover,
			eventMouseout: @eventMouseout
		})