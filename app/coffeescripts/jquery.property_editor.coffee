(($) ->
  $.fn.propertyEditor = (properties) ->
    element = this.eq(0)

    element.addClass("properties")

    element.getProps = () ->
      props = {}

      element.find("tr").each () ->
        inputs = $(this).find("input")

        if key = inputs.eq(0).val()
          value = inputs.eq(1).val()

          try
            props[key] = JSON.parse(value)
          catch e
            props[key] = value

          return # This is necessary because the implicit return in the try catch got weird

      props

    element.setProps = (properties) ->
      element.html('')

      if properties
        $.each properties, addRow

      addRow('', '')

      element

    addRow = (key, value) ->
      row = $ "<tr>"

      cell = $("<td>").appendTo(row)

      $("<input>",
        type: "text"
        placeholder: "key"
        value: key
      ).appendTo cell

      cell = $("<td>").appendTo(row)

      value = JSON.stringify(value) unless typeof value == "string"

      $("<input>",
        type: "text"
        placeholder: "value"
        value: value
      ).appendTo cell

      row.appendTo element

    $('input', this.selector).live 'keydown', (event) ->
      if event.type == "keydown"
        return unless (event.which == 38 || event.which == 40)

      event.preventDefault()

      $this = $(this)

      changeAmount = if event.which == 38 then 1 else -1

      if $this.val().length
        if event.shiftKey
          changeAmount *= 5

          if !isNaN($this.val())
            $this.val(parseInt($this.val()) + changeAmount)
        else
          if $this.val() == "true"
            $this.val("false")
          else if $this.val() == "false"
            $this.val("true")
          else if !isNaN($this.val())
            if parseFloat($this.val()).abs() <= 1
              num = parseFloat($this.val())
              $this.val((num + (0.1 * changeAmount)).toFixed(1))
            else
              $this.val(parseInt($this.val()) + changeAmount)

        element.trigger("change", element.getProps())

    $('input', this.selector).live 'blur', (event) ->
      element.trigger("change", element.getProps())

      $this = $(this)

      if (input = element.find("tr").last().find("input").first()).length
        if input.val()
          addRow('', '')
      else
        addRow('', '')

    element.setProps(properties)

)(jQuery)
