
root = (window || @)

class NotifyDisposeState
  
  constructor: () ->
    @states = {}

  setTypeValue: (type, val) ->
    @states[type] = val

  getType: (type) -> 
    @states[type]    


  
root.notifyDisposeState = new NotifyDisposeState()