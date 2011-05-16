(($) ->
  $.fn.propertyEditor = (properties) ->
    object = properties

    element = this.eq(0)
    element.addClass("properties")

    element.getProps = () ->
      object

    element.setProps = (properties) ->
      object = properties
      element.html('')

      if properties
        propertiesArray = []
        for key, value of properties
          propertiesArray.push [key, value]

        propertiesArray.sort().each (pair) ->
          [key, value] = pair

          if key.match(/color/i)
            addRow(key, value).find('td:last input').colorPicker()
          else if Object.isObject(value) && value.hasOwnProperty('x') && value.hasOwnProperty('y')
            addRow(key, value).find('td:last input').vectorPicker()
          else if Object.isObject(value)
            addNestedRow(key, value)
          else
            addRow(key, value)

      addRow('', '')

      element

    rowCheck = ->
      # If last row has data
      if (input = element.find("tr").last().find("input").first()).length
        if input.val()
          addRow('', '')
      else # Or no rows
        addRow('', '')

    addBlurEvents = (keyInput, valueInput) ->
      keyInput.blur ->
        currentName = keyInput.val()
        previousName = keyInput.data("previousName")

        return if currentName.blank()

        if currentName != previousName
          keyInput.data("previousName", currentName)
          delete object[previousName]
          object[currentName] = valueInput.val()

          element.trigger("change", object)

          rowCheck()

      valueInput.blur ->
        currentValue = valueInput.val().parse()
        previousValue = valueInput.data("previousValue")

        if currentValue != previousValue
          valueInput.data("previousValue", currentValue)
          object[keyInput.val()] = currentValue

          element.trigger("change", object)

          rowCheck()

    addRow = (key, value) ->
      row = $ "<tr>"

      cell = $("<td>").appendTo(row)

      keyInput = $("<input>",
        class: "key"
        data:
          previousName: key
        type: "text"
        placeholder: "key"
        value: key
      ).appendTo(cell)

      cell = $("<td>").appendTo(row)

      value = JSON.stringify(value) unless typeof value == "string"

      valueInput = $("<input>",
        class: "value"
        data:
          previousValue: value
        type: "text"
        placeholder: "value"
        value: value
      ).appendTo(cell)

      addBlurEvents(keyInput, valueInput)

      return row.appendTo(element)

    addNestedRow = (key, value) ->
      row = $("<tr>")
      cell = $("<td colspan='2'>").appendTo(row)

      #TODO: Editable key

      $("<label>",
        text: key
      ).appendTo(cell)

      nestedEditor = $("<table>",
        class: "nested"
      ).appendTo(cell).propertyEditor(value)

      #TODO Cascade change events

      return row.appendTo(element)

    element.setProps(properties)

)(jQuery)
