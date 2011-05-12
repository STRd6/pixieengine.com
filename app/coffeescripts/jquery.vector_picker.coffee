(($) ->
  $.fn.vectorPicker = (options) ->
    options ||= {}

    SIZE = 130
    BORDER_WIDTH = 2
    RADIUS = 7

    dialog = null
    input = null
    choosingVector = false

    setVector = (x, y, element) ->
      xTranslate = ((x - SIZE / 2) / 5).round()
      yTranslate = ((y - SIZE / 2) / 5).round()

      $(element).css('backgroundPosition', "#{x - RADIUS}px #{y - RADIUS}px")
      input.val(JSON.stringify({ x: xTranslate, y: yTranslate }))

    showDialog = (element) ->
      dialog = $('<div class="vector_picker" />')

      $('<div class="unit_circle" />').bind(
        mousedown: (e) ->
          setVector(e.offsetX, e.offsetY, $(this))
          choosingVector = false
          input.select()
        mouseenter: ->
          choosingVector = true
        mousemove: (e) ->
          setVector(e.offsetX, e.offsetY, $(this))
          choosingVector = false
      ).appendTo(dialog)

      inputOffset = $(element).offset()
      inputHeight = element.offsetHeight

      x = inputOffset.left + BORDER_WIDTH
      y = inputOffset.top + BORDER_WIDTH + inputHeight

      dialog.css
        left: x
        top: y

      $('body').append(dialog)

    return this.each ->
      $this = $(this)

      input = $this

      $this.bind
        blur: (e) ->
          $('.vector_picker').remove() unless choosingVector
        focus: ->
          showDialog(this) unless $('.vector_picker').length
)(jQuery)