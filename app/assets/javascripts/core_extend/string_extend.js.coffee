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
  for i, val of formatArray
    value = stringArray[i]
    throw "请指定正确的日期格式" unless value.split(/\W/).length == 1
    time[val] = value
  new Date(time.yyyy || time.yy, ~~(time.MM || time.M) - 1, time.dd || time.d, 
    time.hh || time.h, time.mm || time.m, time.ss || time.s)
