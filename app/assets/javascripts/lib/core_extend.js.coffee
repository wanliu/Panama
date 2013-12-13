#= require lib/jquery_extend
#= require lib/form_extend

root = window || @

# 本地存储存取Hash结构的数据
root.local_storage= (key, value) ->
  if value?
    localStorage[key] = JSON.stringify(value)
  else
    if localStorage[key]? 
      JSON.parse(localStorage[key])
    else
      console.error("localStorage.#{key} no exists!")

Array.prototype.indexOf = (val) ->
  for v, i in @
    if v is val
      return i
  return -1

#去左右空
String.prototype.trim = () ->
	return this.trimLeft().trimRight()

#去左边空
String.prototype.trimLeft = () ->
	return this.replace(/^\s+/, '')

#去右边空
String.prototype.trimRight = () ->
	return this.replace(/\s+$/, '')

#转换为固定小数位的货币格式
String.prototype.toMoney = (scale = 2) ->
	value = parseFloat(this.trim())
	value = 0.0 unless value >= 0
	return "￥#{value.toFixed(scale)}"

String.prototype.toDate = (format = 'yyyy-MM-dd hh:mm:ss') ->
  # date = Date.parse(this)
  # return date unless isNaN(date)
  stringArray = this.split(/\W/)
  formatArray = format.split(/\W/)
  time = {
    "yyyy": '', "MM": '', "dd": '',
    "yy"  : '', "M" : '', "d" : '',
    "hh"  : '', "mm": '', "ss": '',
    "h"   : '', "m" : '', "s" : '' 
  }
  for i in [0..formatArray.length-1]
    val = formatArray[i]
    value = stringArray[i]
    throw "请指定正确的日期格式" unless value.split(/\W/).length == 1
    time[val] = value
  new Date(time.yyyy || time.yy, ~~(time.MM || time.M) - 1, time.dd || time.d, 
    time.hh || time.h, time.mm || time.m, time.ss || time.s)

Date.prototype.format = (format = 'yyyy-MM-dd hh:mm:ss') ->
  yearL = this.getFullYear()
  yearS = yearL.toString().substring(2, 4)
  monthS = this.getMonth()+1
  monthL = if monthS.toString().length==1 then "0"+monthS else monthS
  dayS = this.getDate()
  dayL = if dayS.toString().length==1 then "0"+dayS else dayS

  hourS = this.getHours()
  hourL = if hourS.toString().length==1 then "0"+hourS else hourS
  minuteS = this.getMinutes()
  minuteL = if minuteS.toString().length==1 then "0"+minuteS else minuteS
  secondS = this.getSeconds()
  secondL = if secondS.toString().length==1 then "0"+secondS else secondS

  m = {
    "yyyy": yearL, "MM" : monthL,  "dd" : dayL,
    "yy"  : yearS, "M"  : monthS,  "d"  : dayS,
    "hh"  : hourL, "mm" : minuteL, "ss" : secondL,
    "h"   : hourS, "m"  : minuteS, "s"  : secondS
  }
  for key, val of m
    format = format.replace(key,val)
  return format

