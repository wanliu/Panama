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
	value = parseFloat(this.trim()).toFixed(scale)
	value = 0 unless parseFloat(value) > 0
	return "￥#{value}"