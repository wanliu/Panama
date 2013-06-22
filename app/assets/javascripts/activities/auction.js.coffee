# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require jquery
#= require backbone
#= require lib/activity_base_info

root = window || @

class root.Choice extends Backbone.View
  
  initialize: (options) ->    
    _.extend(@, options)
    @el = $(".form_activity_auction")
    @$el = $(@el)

  events:
    "blur #activity_product" : "hide",
    "keyup #activity_product" : "query",
    "click ul.product_selector>li" : "listening"

  hide:(event)->
    window.setTimeout () ->
      @$("ul.product_selector").hide()
    , 500
   
  query: (event) ->
    debugger
    query_name = @$("#activity_product").val().trim()
    return if query_name == "" 
    $.ajax
      url: "product_search/?q=" + query_name
      beforeSend: (xhr)->
        xhr.overrideMimeType("text/json; charset=x-user-defined")
      success:(data)=> 
        select_ul = ""       
        if data.length > 0 
          $.each(data, (i, d) =>                       
            select_ul += "<li product_id=#{d.id}
                  product_price=#{d.price}>
                  <a tabindex='-1' href='javascript: void(0);'>
                  #{d.title}</a></li>")
        select_ul = select_ul || "<li><a tabindex='-1' href='javascript: void(0);'>没有相关商品！</a></li>"
        @$("ul.product_selector").html(select_ul)
        @$("ul.product_selector").show()


  listening:(event)->
    product_id =  $(event.currentTarget).attr('product_id')  
    return if !product_id 
    product_name = $(event.currentTarget).text().trim()
    @$("#activity_product").val(product_name)
    @$("#activity_description").val(product_name + "竞价") 
    activity_view.fetch_product(product_id)