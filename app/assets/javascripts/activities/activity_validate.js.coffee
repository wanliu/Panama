
root = window || @

class root.Validate
  constructor: (options) ->
    _.extend(@, options)
    if _.contains(@el.attr('action').split("/"), "auction")
      @validate = new AuctionValidate({el: @el}).validate()
    if _.contains(@el.attr('action').split("/"), "focus")
      @validate = new FocusValidate({el: @el}).validate()

class AuctionValidate
  constructor: (options) ->
    _.extend(@, options)
    @title = @el.find("[name='activity[title]']");
    @price = @el.find("[name='activity[price]']");
    @activity_price = @el.find("[name='activity[activity_price]']");
    @shop_product_id = @el.find("[name='activity[shop_product_id]']");
    @title.on("keyup", @validate_title)
    @price.on("keyup", @validate_price)
    @activity_price.on("keyup", @validate_activity_price)
    # @validate()

  validate_title: () ->
    $(@).removeClass('error') unless _.isEmpty($(@).val())

  validate_price: () ->
    $(@).removeClass('error') unless _.isEmpty($(@).val())
    if isNaN($(@).val())
      $(@).addClass('error')

  validate_activity_price: () ->
    $(@).removeClass('error') unless _.isEmpty($(@).val())
    if isNaN($(@).val())
      $(@).addClass('error')
   
  validate: () ->
    if _.isEmpty(@shop_product_id.val())
      @el.find("#activity_auction_shop_product_chzn").addClass('error')
      return false

    if _.isEmpty(@title.val())
      @title.addClass('error')
      return false

    if _.isEmpty(@price.val()) || isNaN(@price.val()) || @price.val() <= 0
      @price.addClass('error')
      return false

    if _.isEmpty(@activity_price.val()) || isNaN(@activity_price.val()) || @activity_price.val() <= 0
      @activity_price.addClass('error')
      return false
    return true

class root.FocusValidate
  constructor: (options) ->
    _.extend(@, options)
    @title = @el.find("[name='activity[title]']");
    @shop_product_id = @el.find("[name='activity[shop_product_id]']");
    @activity_number = @el.find("#activity_people_number")
    @activity_price = @el.find("#activity_activity_price")

    @title.on("keyup", @validate_title)   
    @activity_number.on("keyup", @validate_activity_number)
    @activity_price.on("keyup", @validate_activity_price)
    # @validate()

  validate_title: () ->
    $(@).removeClass('error') unless _.isEmpty($(@).val())

  validate_activity_price: () ->
    $(@).removeClass('error') unless _.isEmpty($(@).val())
    if isNaN($(@).val())
      $(@).addClass('error')

  validate_activity_number: () ->
    $(@).removeClass('error') unless _.isEmpty($(@).val())
    if isNaN($(@).val())
      $(@).addClass('error')
   
  validate: () ->
    if _.isEmpty(@shop_product_id.val())
      @el.find("#activity_auction_shop_product_chzn").addClass('error')
      return false

    if _.isEmpty(@title.val())
      @title.addClass('error')
      return false

    if _.isEmpty(@activity_number.val()) || isNaN(@activity_number.val())
      @activity_number.addClass('error')
      return false

    if _.isEmpty(@activity_price.val()) || isNaN(@activity_price.val()) || @activity_price.val() <= 0
      @activity_price.addClass('error')
      return false

    return true