(($) ->
  $.fn.propertyEditor = (properties) ->
    element = this.eq(0)

    element.addClass("properties")

    element.getProps = () ->
      props = {}

      element.find("tr").each () ->
        inputs = $(this).find("input")

        if key = inputs.eq(0).val()
          props[key] = inputs.eq(1).val()

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
        value: key
      ).appendTo cell

      cell = $("<td>").appendTo(row)

      $("<input>",
        type: "text"
        value: value
      ).appendTo cell

      row.appendTo element

    $('input', this.selector).live 'blur', (event) ->
      $this = $(this)

      if (input = element.find("tr").last().find("input").first()).length
        if input.val()
          addRow('', '')
      else
        addRow('', '')

    element.setProps(properties)

)(jQuery)
