(($) ->
  $.event.fix = ((originalFix) ->
    (event) ->
      event = originalFix.apply(this, arguments)

      if event.type.indexOf('drag') == 0 || event.type.indexOf('drop') == 0
        event.dataTransfer = event.originalEvent.dataTransfer

      event

  )($.event.fix)

  defaults =
    callback: $.noop
    matchType: /image.*/

  $.fn.dropImageReader = (options) ->
    if typeof options == "function"
      options =
        callback: options

    options = $.extend({}, defaults, options)

    stopFn = (event) ->
      event.stopPropagation()
      event.preventDefault()

    this.each () ->
      element = this
      $this = $(this)

      $this.bind 'dragenter dragover dragleave', stopFn

      $this.bind 'drop', (event) ->
        stopFn(event)

        Array::forEach.call event.dataTransfer.files, (file) ->
          return unless file.type.match(options.matchType)

          reader = new FileReader()

          reader.onload = (evt) ->
            options.callback.call(element, file, evt)

          reader.readAsDataURL(file)

)(jQuery)
