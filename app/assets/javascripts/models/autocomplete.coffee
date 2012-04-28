namespace "Pixie.Models", (Models) ->
  class Models.Autocomplete extends Backbone.Model
    defaults:
      suggestions: {
        self: []
        I: []
        global: []
      }
      selectedIndex: 0
      filterLength: 0

    # TODO have a hash table for different method contexts.
    # 1. global
    # 2. self.
    # 3. I.

    initialize: ->
      try
        {text} = @attributes

        nodes = CoffeeScript.nodes(text)

        @set
          suggestions: {
            self: @generateInstanceMethods(nodes)
            I: @generateInstanceProperties(nodes)
          }

    generateInstanceMethods: (nodes) ->
      returnValue = []

      nodes.traverseChildren true, (node) ->
        # Find self methods
        if node.variable?.base.value == "self" and (valueNode = node.value)
          # We have assigned something to the self variable
          if valueNode.variable?.properties.first()?.name.value == "extend"
            # We're using extend on the parent class
            if parentClassName = valueNode.variable?.base.variable.base.value
              console.log "ParentClass: #{parentClassName}"

            if keys = valueNode.args?.first()?.base.objects
              returnValue = keys.map (keyNode) ->
                keyNode.variable.base.value

      return returnValue

    generateInstanceProperties: (nodes) ->
      returnValue = []

      nodes.traverseChildren true, (node) ->
        # Find 'I' properties
        if node.variable?.properties?.first()?.name?.value is "reverseMerge"
          if node.variable.base.value == "$" or node.variable.base.value == "Object"
            if node.args.first()?.base.value is "I"
              if keys = node.args[1]?.base.objects
                returnValue = keys.map (keyNode) ->
                  keyNode.variable.base.value

      return returnValue

    decrementSelected: =>
      @_shiftSelected(-1)

    suggestions: (context) =>
      {suggestions} = @attributes

      if context is 'self'
        suggestions['self'].copy().sort()
      else if context is 'I'
        suggestions['I'].copy().sort()
      else
        []

    filterSuggestions: (context, currentString) =>
      {editor, suggestions} = @attributes

      cursorPosition = editor.getCursor()

      currentLine = editor.lineInfo(cursorPosition.line).text
      lastToken = currentLine.split(' ').last()

      [unusedTokens..., context, currentString] = lastToken.split('.')

      output = (@suggestions(context).map (suggestion) ->
        suggestion if suggestion.indexOf(currentString) is 0
      ).compact()

      @set
        filterLength: output.length

      return output

    incrementSelected: =>
      @_shiftSelected(+1)

    _shiftSelected: (value) =>
      {editor, filterLength, selectedIndex} = @attributes

      cursorPosition = editor.getCursor()

      currentToken = editor.getTokenAt(editor.coordsChar(cursorPosition)).string

      @set
        selectedIndex: (selectedIndex + value).mod(filterLength)

