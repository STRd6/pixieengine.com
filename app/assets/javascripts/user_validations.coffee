$ ->
  ILLEGAL_CHARS = [
    190 # .
  ]

  addWarnings = (element) ->
    element.tipsy
      gravity: 'w'
      trigger: 'manual'

    element.tipsy 'show'
    element.css
      border: '1px solid red'

  removeWarnings = (element) ->
    element.tipsy 'hide'
    element.css
      border: '1px solid rgb(170, 170, 170)'

  $('#user_display_name').blur (e) ->
    $this = $(this)

    if $this.val().match /[.]/
      addWarnings $this
    else
      removeWarnings $this

  $('#user_display_name').keydown (e) ->
    $this = $(this)

    for illegalKey in ILLEGAL_CHARS
      if e.keyCode is illegalKey
        addWarnings $this

        return false
      else
        removeWarnings $this
