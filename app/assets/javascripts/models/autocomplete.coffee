namespace "Pixie.Models", (Models) ->
  class Models.Autocomplete extends Backbone.Model
    defaults:
      suggestions: {
        self: []
        I: []
        global: []
      }
      filteredSuggestions: []
      selectedIndex: 0

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

    getCurrentToken: =>
      {editor} = @attributes

      cursorPosition = editor.getCursor()

      return editor.getTokenAt(cursorPosition).string.replace(/[^\w]/g, '')

    currentSuggestion: =>
      @get('filteredSuggestions')[@get('selectedIndex')]

    decrementSelected: =>
      @_shiftSelected(-1)

    filterSuggestions: =>
      {editor, suggestions} = @attributes

      cursorPosition = editor.getCursor()
      currentToken = editor.getTokenAt(cursorPosition)

      previousPosition = {ch: cursorPosition.ch - 1, line: cursorPosition.line}
      previousToken = editor.getTokenAt(previousPosition)

      line = cursorPosition.line

      currentString = editor.getRange({line: line, ch: currentToken.start}, {line: line, ch: cursorPosition.ch}).replace(/[^\w]/g, '')
      previousString = previousToken.string

      if previousString is 'self'
        @set
          filteredSuggestions: suggestions['self'].copy().sort()
      else if currentString is ''
        @set
          filteredSuggestions: suggestions['I'].copy().sort()

        return currentString

      matches = suggestions['I'].map (suggestion) ->
        suggestion if suggestion.indexOf(currentString) is 0

      if matches.compact().length
        @set
          filteredSuggestions: matches.compact().sort()
      else
        @set
          filteredSuggestions: suggestions['I'].copy().sort()

      return currentString

    incrementSelected: =>
      @_shiftSelected(+1)

    _shiftSelected: (value) =>
      {editor, filteredSuggestions, selectedIndex} = @attributes

      cursorPosition = editor.getCursor()

      currentToken = editor.getTokenAt(editor.coordsChar(cursorPosition)).string

      @set
        selectedIndex: (selectedIndex + value).mod(filteredSuggestions.length)

