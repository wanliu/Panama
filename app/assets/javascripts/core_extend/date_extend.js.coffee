Date.prototype.format = (format = 'yyyy-MM-dd hh:mm:ss') ->
  _year_long = this.getFullYear()
  _year_short = _year_long.toString().substring(2, 4)

  _month = this.getMonth()+1
  _month_long = if _month.toString().length==1 then "0"+_month else _month
  _month_short = if _month.toString().length==1 then ""+_month else _month

  _day = this.getDate()
  _day_long = if _day.toString().length==1 then "0"+_day else _day
  _day_short = if _day.toString().length==1 then ""+_day else _day

  _hours = this.getHours()
  _hours_long = if _hours.toString().length==1 then "0"+_hours else _hours
  _hours_short = if _hours.toString().length==1 then ""+_hours else _hours

  _minutes = this.getMinutes()
  _minutes_long = if _minutes.toString().length==1 then "0"+_minutes else _minutes
  _minutes_short = if _minutes.toString().length==1 then ""+_minutes else _minutes
  
  _seconds = this.getSeconds()
  _seconds_long = if _seconds.toString().length==1 then "0"+_seconds else _seconds
  _seconds_short = if _seconds.toString().length==1 then ""+_seconds else _seconds

  m = {
    "yyyy": _year_long,  "MM" : _month_long,   "dd" : _day_long,
    "yy"  : _year_short, "M"  : _month_short,  "d"  : _day_short,
    "hh"  : _hours_long, "mm" : _minutes_long, "ss" : _seconds_long,
    "h"   : _hours_short,"m"  : _minutes_short,"s"  : _seconds_short
  }

  for key, val of m
    format = format.replace(key,val)
  return format