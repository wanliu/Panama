#= require twitter/bootstrap/modal

(($) ->

  modal = $.fn.modal.Constructor

  old_backdrop = modal.prototype.backdrop 

  modal.prototype.backdrop = () ->  
    return if this.isShown && this.options.backdrop && @$backdrop    
    old_backdrop.apply(@, arguments)

)(window.jQuery)