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

    $('input', this.selector).live 'keydown', (event) ->
      return unless event.type == "keydown"
      return unless (event.which == 13 || event.which == 37 || event.which == 38 || event.which == 39 || event.which == 40)

      if event.which == 13
        nextValue($(this))
        return

      event.preventDefault()

      $this = $(this)

      changeAmount = if event.which == 38 then 1 else -1

      nextValue = (input) ->
        $(input).parent().parent().next().find('td:last input').select()

      flipBoolean = (bool) ->
        if bool == "true"
          "false"
        else if bool == "false"
          "true"
        else
          false

      changeNumber = (value, direction) ->
        if parseFloat(value).abs() < 1
          num = parseFloat(value)
          return (num + (0.1 * changeAmount)).toFixed(1)
        else if parseInt(value) == 1
          num = parseInt(value)
          if event.which == 38
            return num + changeAmount
          else
            return (num - 0.1).toFixed(1)
        else if parseInt(value) == -1
          num = parseInt(value)
          if event.which == 38
            return (num + 0.1).toFixed(1)
          else
            return num + changeAmount
        else
          return parseInt(value) + changeAmount

      changeObject = (obj, key) ->
        switch key
          when 37 then obj.x--
          when 38 then obj.y--
          when 39 then obj.x++
          when 40 then obj.y++

        return JSON.stringify(obj)

      value = $this.val()

      if value.length
        result = null

        changeAmount *= 10 if (event.shiftKey && Number.isNumber value)

        element.trigger("change", element.getProps())

        try
          obj = JSON.parse(value)
        catch e
          obj = null

        if flipBoolean value
          result = flipBoolean value
        else if Number.isNumber value
          result = changeNumber(value, changeAmount)
        else if obj && obj.hasOwnProperty('x') && obj.hasOwnProperty('y')
          result = changeObject(obj, event.which)

        $this.val(result)

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
