(($) ->
  $.event.fix = ((originalFix) ->
    (event) ->
      event = originalFix.apply(this, arguments)

      if event.type.indexOf('drag') == 0 || event.type.indexOf('drop') == 0
        event.dataTransfer = event.originalEvent.dataTransfer

      event

  )($.event.fix)

  $.fn.dropImageReader = (callback) ->
    stopFn = (event) ->
      event.stopPropagation()
      event.preventDefault()

    this.each () ->
      element = this
      $this = $(this)

      $this.bind 'dragenter dragover dragleave', stopFn

      $this.bind 'drop', (event) ->
        stopFn(event)

        Array.prototype.forEach.call event.dataTransfer.files, (file) ->
          imageType = /image.*/
          if !file.type.match(imageType)
            return

          reader = new FileReader()

          reader.onload = (evt) ->
            callback.call(element, file, evt)

          reader.readAsDataURL(file)

)(jQuery)
