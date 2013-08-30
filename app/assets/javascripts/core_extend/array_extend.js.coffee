
Array.prototype.indexOf = (val) ->
  for v, i in @
    if v is val
      return i

  return -1