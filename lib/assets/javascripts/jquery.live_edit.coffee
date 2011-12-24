(($) ->
  $.fn.liveEdit = (selector, options) ->
    @on 'dblclick', selector, ->
      $this = $(this)

      return if $this.is("input")

      textInput = $("<input/>",
        class: $this.attr("class")
        "data-origType": this.tagName
        id: $this.attr("id") || null
        type: "text"
        value: $.trim($this.text())
      )

      $this.replaceWith textInput

      textInput.focus().select()

    @on 'blur keydown', selector, (event) ->
      if event.type == "keydown"
        return unless event.which == 13 || event.which == 9

      $this = $(this)

      return if $this.attr("data-removed")
      return unless $this.is("input")

      $this.attr("data-removed", true)
      text = $this.val()

      newElement = $("<" + $this.attr("data-origType") + " />",
        class: $this.attr("class")
        id: $this.attr("id") || null
        text: text
      )

      $this.replaceWith newElement

      if options.change
        options.change(newElement, text)

    return this

)(jQuery)
