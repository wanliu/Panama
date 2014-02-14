#describe: 商店帖子分类

root = window || @

class ShopCategory extends Backbone.Model
  urlRoot: "/shops"

  category: (callback) ->
    @fetch({
      url: "#{@urlRoot}/topic_categories/#{@id}",
      success: callback
      })

class ShopCategoryList extends Backbone.Collection
  model: ShopCategory

class ShopCategoryView extends Backbone.View
  tagName: "select"
  initialize: (opts) ->
    _.extend(@, opts)
    @$el = $(@el)
    @$el.attr("name", "topic_category_id")
    @model.bind("render", _.bind(@render, @))
    @model.category (model, data) =>
      _.each data, (category) =>
        @$el.append("<option value='#{category.id}'>#{category.name}</option>")
      @render()


  render: () ->
    @parent_el.html(@el)


class ShopCategoryViewList extends Backbone.View

  initialize: (opts) ->
    _.extend(@, opts)
    @shop_category_list = new ShopCategoryList()
    @shop_category_list.bind("add", @add_view, @)

  add: (model) ->
    _model = @shop_category_list.get(model.id)
    if _model?
      _model.trigger("render")
    else
      @shop_category_list.add(model)
    @show()

  show: () ->
    @el.show()

  hide: () ->
    @el.hide()

  add_view: (model) ->
    new ShopCategoryView(parent_el: @el, model: model)


root.ShopCategoryViewList = ShopCategoryViewList