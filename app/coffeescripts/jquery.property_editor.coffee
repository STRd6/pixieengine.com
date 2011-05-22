(($) ->
  createCodeMirrorEditor = (textArea) ->
    code = textArea.val()
    lang = "coffeescript"

    editor = new CodeMirror.fromTextArea textArea.get(0),
      autoMatchParens: true
      content: code
      lineNumbers: true
      parserfile: ["tokenize_" + lang + ".js", "parse_" + lang + ".js"]
      path: "/javascripts/codemirror/"
      stylesheet: ["/stylesheets/codemirror/main.css"]
      tabMode: "shift"
      textWrapping: false

    $(editor.win.document).find('html').toggleClass('light', $("#bulb").hasClass('on'))

    # Listen for keypresses and update contents.
    $(editor.win.document).keyup ->
      textArea.val(editor.getCode())
      textArea.trigger('blur')

  $.fn.propertyEditor = (properties) ->
    properties ||= {}
    object = properties

    element = this.eq(0)
    element.addClass("properties")

    element.getProps = () ->
      object

    isCodeField = (key, value) ->
      ["create", "step", "update", "destroy"].include(key)

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

          if key.match(/color/i)
            addRow(key, value).find('td:last input').colorPicker
              leadingHash: true
          else if isCodeField(key, value)
            createCodeMirrorEditor(addRow(key, value, valueInputType: "textarea").find('td:last textarea'))
          else if Object.isObject(value) && value.hasOwnProperty('x') && value.hasOwnProperty('y')
            addRow(key, value).find('td:last input').vectorPicker()
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

    addBlurEvents = (keyInput, valueInput) ->
      keyInput.blur ->
        currentName = keyInput.val()
        previousName = keyInput.data("previousName")

        return if currentName.blank()

        if currentName != previousName
          keyInput.data("previousName", currentName)
          delete object[previousName]
          object[currentName] = valueInput.val()

          try
            element.trigger("change", object)
          catch error
            console?.error? error

          rowCheck()

      valueInput.blur ->
        currentValue = valueInput.val().parse()
        previousValue = valueInput.data("previousValue")

        if currentValue != previousValue
          valueInput.data("previousValue", currentValue)
          object[keyInput.val()] = currentValue

          try
            element.trigger("change", object)
          catch error
            console?.error? error

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
