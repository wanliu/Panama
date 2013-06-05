#去左右空
String.prototype.trim = () ->
  return this.toString().replace(/^\s+/,'').replace(/\s+$/,'')

#去左边空
String.prototype.trimLeft = () ->
  return this.toString().replace(/^\s+/,'')

#去右边空
String.prototype.trimRight = () ->
  return this.toString().replace(/\s+$/,'')