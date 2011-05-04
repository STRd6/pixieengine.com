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
        $.each properties, addRow

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

      if $this.val().length
        if event.shiftKey
          changeAmount *= 10

          if !isNaN($this.val())
            $this.val(parseInt($this.val()) + changeAmount)
        else
          if $this.val() == "true"
            $this.val("false")
          else if $this.val() == "false"
            $this.val("true")
          else if !isNaN($this.val())
            if parseFloat($this.val()).abs() < 1
              num = parseFloat($this.val())
              $this.val((num + (0.1 * changeAmount)).toFixed(1))
            else if parseInt($this.val()) == 1
              num = parseInt($this.val())
              if event.which == 38
                $this.val(num + 1)
              else
                $this.val((num - 0.1).toFixed(1))
            else if parseInt($this.val()) == -1
              num = parseInt($this.val())
              if event.which == 38
                $this.val(num + 0.1).toFixed(1)
              else
                $this.val(num - 1)
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
