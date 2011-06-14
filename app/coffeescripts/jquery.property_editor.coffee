(($) ->
  events = ["create", "step", "update", "destroy"]

  hiddenFields = events.eachWithObject [], (event, array) ->
    array.push event, event + "Coffee"

  shouldHide = (key, value) ->
    hiddenFields.include(key) || $.isFunction(value)

  $.fn.propertyEditor = (properties) ->
    properties ||= {}
    object = properties

    element = this.eq(0)
    element.addClass("properties")

    element.getProps = () ->
      object

    element.setProps = (properties) ->
      properties ||= {}
      object = properties

      element.html('')

      if properties
        propertiesArray = []
        for key, value of properties
          propertiesArray.push [key, value]

        propertiesArray.sort().each (pair) ->
          [key, value] = pair

          if shouldHide(key, value)
            # Skip
          else if key.match(/color/i)
            addRow(key, value).find('td:last input').colorPicker
              leadingHash: true
          else if Object.isObject(value)
            addNestedRow(key, value)
          else if value?.match?(/^data:image\//)
            addRow(key, value).find('td:last input').modalPixelEditor(properties)
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

    fireChangedEvent = ->
      try
        element.trigger("change", [object])
      catch error
        console?.error? error

    addBlurEvents = (keyInput, valueInput) ->
      keyInput.blur ->
        currentName = keyInput.val()
        previousName = keyInput.data("previousName")

        if currentName != previousName
          keyInput.data("previousName", currentName)
          delete object[previousName]

          return if currentName.blank()

          object[currentName] = valueInput.val()

          fireChangedEvent()

          rowCheck()

      valueInput.blur ->
        currentValue = valueInput.val().parse()
        previousValue = valueInput.data("previousValue")

        if currentValue != previousValue
          return unless key = keyInput.val()

          valueInput.data("previousValue", currentValue)
          object[key] = currentValue

          fireChangedEvent()

          rowCheck()

    addRow = (key, value, options={}) ->
      row = $ "<tr>"

      keyInput = $("<input>",
        class: "key"
        data:
          previousName: key
        type: "text"
        placeholder: "key"
        value: key
      ).appendTo($("<td>").appendTo(row))

      value = JSON.stringify(value) unless typeof value == "string"

      valueInputType = options.valueInputType || "input"

      valueInput = $("<#{valueInputType}>",
        class: "value"
        data:
          previousValue: value
        type: "text"
        placeholder: "value"
        value: value
      ).appendTo($("<td>").appendTo(row))

      addBlurEvents(keyInput, valueInput)

      return row.appendTo(element)

    addNestedRow = (key, value) ->
      row = $("<tr>")
      cell = $("<td colspan='2'>").appendTo(row)

      $("<label>",
        text: key
      ).appendTo(cell)

      nestedEditor = $("<table>",
        class: "nested"
      ).appendTo(cell).propertyEditor(value)

      # Prevent event bubbling and retrigger with parent object
      nestedEditor.bind "change", (event, changedNestedObject) ->
        event.stopPropagation()
        fireChangedEvent()

      return row.appendTo(element)

    element.setProps(properties)

)(jQuery)
