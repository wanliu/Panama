#= require lib/realtime_client

root = window || @


# class TransactionList extends Backbone.Collection
#   model: Transaction
#   url: 'people/transactions'

class TransactionStateChange extends Backbone.View

	initialize: (options) ->
		_.extend(@, options)
		# @transactions = new TransactionList()
		# @transactions.bind("change", @notice_user, @)
		@bind_realtime()

	bind_realtime: () ->
		@client = Realtime.client(@realtime_url)

		@client.subscribe "/change_state/messages", (info) =>
			@realtime_change(info, 'transactions')

	realtime_change: (data, type) ->
    model = @transactions.where(id: data.id, _type: type).first
    if model?
      model.set("state_title", data.state_title)
    alert(data.state_title)

root.TransactionStateChange = TransactionStateChange