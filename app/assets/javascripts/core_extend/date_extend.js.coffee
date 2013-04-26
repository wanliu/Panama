Date.prototype.format = (format) ->
  _month = this.getMonth()+1
  _month = if _month.toString().length==1 then "0"+_month else _month
  _day = this.getDate()
  _day = if _day.toString().length==1 then "0"+_day else _day
  _hours = this.getHours()
  _hours = if _hours.toString().length==1 then "0"+_hours else _hours
  _minutes = this.getMinutes()
  _minutes = if _minutes.toString().length==1 then "0"+_minutes else _minutes

  m = {
    "yyyy" : this.getFullYear(),                             #年
    "MM"   : _month,                                           #月
    "dd"   : _day,                                             #天
    "h"    : _hours,                                            #时
    "m"    : _minutes,                                          #分
    "s"    : this.getSeconds(),                                 #秒
    "S"    : this.getMilliseconds()                             #毫秒
  }

  for key , val of m
    format = format.replace(key,val)
  return format