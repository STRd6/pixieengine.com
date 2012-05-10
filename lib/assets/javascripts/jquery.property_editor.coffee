(($) ->
  events = ["create", "step", "update", "destroy"]

  hiddenFields = events.eachWithObject [], (event, array) ->
    array.push event, event + "Coffee"

  hiddenFields.push '__CODE'

  shouldHide = (key, value) ->
    hiddenFields.include(key) or $.isFunction(value)

  $.fn.propertyEditor = (properties) ->
    properties ||= {}
    object = properties

    element = this.eq(0)
    element.addClass("properties")

    element.getProps = ->
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
          else if $.isNumeric(value)
            addRow key, value,
              inputType: 'number'
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

    fireDirtyEvent = ->
      try
        element.trigger("dirty", [object])
      catch error
        console?.error? error

    processInputChanges = ->
      fireDirtyEvent()

      rowCheck()

    addChangeEvents = (keyInput, valueInput) ->
      keyInput.bind 'blur keyup', (e) ->
        $this = $(this)

        currentName = $this.val()
        previousName = $this.data("previousName")

        if currentName isnt previousName
          $this.data("previousName", currentName)
          delete object[previousName]

          return if currentName.blank()

          object[currentName] = valueInput.val()

          processInputChanges()

      valueInput.bind 'keydown', (e) ->
        if e.shiftKey
          $(this).attr('step', 10)
        if e.altKey
          $(this).attr('step', 0.1)

      valueInput.bind 'blur keyup', (e) ->
        $this = $(this)

        $this.removeAttr('step')

        currentValue = $this.val().parse()
        previousValue = $this.data("previousValue")

        if currentValue isnt previousValue
          return unless key = keyInput.val()

          $this.data("previousValue", currentValue)
          object[key] = currentValue

          processInputChanges()

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

      unless typeof value == "string" || typeof value == "number"
        value = JSON.stringify(value)

      valueInputType = options.valueInputType || "input"
      inputType = options.inputType || "text"

      valueInput = $("<#{valueInputType}>",
        class: "value"
        data:
          previousValue: value
        type: inputType
        placeholder: "value"
        value: value
      ).appendTo($("<td>").appendTo(row))

      addChangeEvents(keyInput, valueInput)

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
        fireDirtyEvent()

      return row.appendTo(element)

    element.setProps(properties)

)(jQuery)
