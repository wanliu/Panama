#= require 'jquery'

root = window || @

# 本地存储存取Hash结构的数据
root.local_storage= (key, value) ->
  if value?
    localStorage[key] = JSON.stringify(value)
  else
    if localStorage[key]? 
      JSON.parse(localStorage[key])
    # else
    #   console.log("localStorage.#{key} no exists!")