root = (window || @)

class Transaction extends Backbone.Model

  load_template: (callback = () ->) ->
    $.ajax(
      url: "#{@url()}/page",
      success: callback
    )
class Transactions extends Backbone.Collection
  model: Transaction

class TransactionList extends Backbone.View

	el: ".transaction-list"
	child: ".order_item"

	initialize: () ->
		$.extend(@, @options)
    @transactions = new Transactions()
    @transactions.url = @remote_url
    @transactions.bind("add", @addView, @)

	loadView: () ->

