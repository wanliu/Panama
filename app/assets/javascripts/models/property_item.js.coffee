#= require jquery
#= require backbone
exports = window || @

class PropertyItem extends Backbone.Model


class PropertyItemCollection extends Backbone.Collection

	model: PropertyItem


exports.PropertyItem = PropertyItem
exports.PropertyItemCollection = PropertyItemCollection
exports