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

      populateParentObjects()

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

    populateParentObjects = () ->
      element.find('tr > tr.child_property').parent().each (i, group) ->
        props = {}

        $(group).find('tr.child_property').each (i, row) ->
          inputs = $(row).find('input')

          key = inputs.eq(0).val().substring(inputs.eq(0).val().search(/\./) + 1)
          value = inputs.eq(1).val()

          if !isNaN(value)
            value = parseFloat(value)

          try
            props[key] = JSON.parse(value)
          catch e
            props[key] = value

          return

        $(group).find('> td input').eq(1).val(JSON.stringify(props))

    generateChildElements = (childData, parentName) ->
      results = []

      for key, value of childData
        row = $ "<tr class='child_property'>"

        key_cell = $ "<td><input type='text' placeholder='key', value=#{parentName}.#{key}></td>"
        value_cell = $ "<td><input type='text' placeholder='value', value=#{value}></td>"

        results.push(row.append(key_cell, value_cell))

      return results

    addRow = (key, value) ->
      row = $ "<tr>"

      cell = $("<td>").appendTo(row)

      $("<input>",
        type: "text"
        placeholder: "key"
        value: key
      ).appendTo cell

      cell = $("<td>").appendTo(row)

      if Object::toString.call(value) == '[object Object]'
        obj = JSON.parse(JSON.stringify(value))

      value = JSON.stringify(value) unless typeof value == "string"

      $("<input>",
        type: "text"
        placeholder: "value"
        value: value
      ).appendTo cell

      if obj
        generateChildElements(obj, key).each (childRow) ->
          childRow.appendTo row

      row.appendTo element

    $('input', this.selector).live 'keydown', (event) ->
      return unless event.type == "keydown"
      return unless (event.which == 38 || event.which == 40)

      event.preventDefault()

      $this = $(this)

      changeAmount = if event.which == 38 then 1 else -1

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

      value = $this.val()

      if value.length
        result = null

        changeAmount *= 10 if (event.shiftKey && Number.isNumber value)

        element.trigger("change", element.getProps())

        if flipBoolean value
          result = flipBoolean value
        else if Number.isNumber value
          result = changeNumber(value, changeAmount)

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
