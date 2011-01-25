(($) ->
  $.fn.liveEdit = () ->
    this.live 'dblclick', () ->
      $this = $(this)

      return if $this.is("input")

      textInput = $("<input/>",
        class: $this.attr("class")
        "data-origType": this.tagName
        id: if id = $this.attr("id") then id else null
        type: "text"
        value: $.trim($this.text())
      )

      $this.replaceWith textInput

      textInput.focus().select()

    this.live 'blur keydown', (event) ->
      if event.type == "keydown"
        return unless event.which == 13 || event.which == 9

      $this = $(this)

      return if $this.data("removed")
      return unless $this.is("input")

      $this.attr("data-removed", true)

      $this.replaceWith $("<" + $this.data("origType") + " />",
        class: $this.attr("class")
        id: if id = $this.attr("id") then id else null
        text: $this.val()
      )

    return this

)(jQuery)
