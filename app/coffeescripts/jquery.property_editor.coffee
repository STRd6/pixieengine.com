(($) ->
  $.fn.propertyEditor = (properties) ->
    element = this.eq(0)

    element.addClass("properties")

    element.getProps = () ->
      props = {}

      element.find("tr:not(.child_property)").each () ->
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
        for key, value of properties
          if key.match(/color/i)
            addRow(key, value).find('td:last input').colorPicker()
          else if Object.isObject(value) && value.hasOwnProperty('x') && value.hasOwnProperty('y')
            addRow(key, value).find('td:last input').vectorPicker()
          else
            addRow(key, value)

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
