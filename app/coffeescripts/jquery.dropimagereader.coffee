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

      content = $this.children()

      $this.bind 'dragenter dragover', (event) ->
        stopFn(event)

        div = $ "<div>",
          class: "drag_drop_placeholder"

        big = $ "<p>",
          class: "big"
          text: "drag images here"

        small = $ "<p>",
          class: "small"
          text: "to post them to chat"

        div.append(big, small)

        $this.css
          width: $this.width()
          height: $this.height()

        $this.children().remove()
        $this.append(div)

      $this.bind 'dragleave drop', (event) ->
        stopFn(event)

        $this.children().remove()
        $this.append(content)

      $this.bind 'drop', (event) ->
        Array.prototype.forEach.call event.dataTransfer.files, (file) ->
          imageType = /image.*/
          if !file.type.match(imageType)
            return

          reader = new FileReader()

          reader.onload = (evt) ->
            callback.call(element, file, evt)

          reader.readAsDataURL(file)

)(jQuery)
