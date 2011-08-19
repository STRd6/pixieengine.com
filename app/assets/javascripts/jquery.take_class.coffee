(($) ->
  $.fn.takeClass = (name) ->
    this.addClass(name).siblings().removeClass(name)

    return this
)(jQuery)
