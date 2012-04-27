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

    setFilterType: (context, currentString) =>
      {suggestions} = @attributes

      if context is 'self.'
        @set
          filteredSuggestions: suggestions['self'].copy().sort()
      else if context is 'I.'
        @set
          filteredSuggestions: suggestions['I'].copy().sort()

      @matchSuggestions(currentString)

    matchSuggestions: (currentString) =>
      matches = @get('filteredSuggestions').map (suggestion) ->
        debugger
        suggestion if suggestion.indexOf(currentString) is 0

      if matches.compact().length
        @set
          filteredSuggestions: matches.compact().sort()

    filterSuggestions: =>
      {editor, suggestions} = @attributes

      cursorPosition = editor.getCursor()

      currentString = @getCurrentToken()

      currentLine = editor.lineInfo(cursorPosition.line).text
      context = currentLine.split(' ').last()

      @setFilterType(context, currentString)

      return currentString

    incrementSelected: =>
      @_shiftSelected(+1)

    _shiftSelected: (value) =>
      {editor, filteredSuggestions, selectedIndex} = @attributes

      cursorPosition = editor.getCursor()

      currentToken = editor.getTokenAt(editor.coordsChar(cursorPosition)).string

      @set
        selectedIndex: (selectedIndex + value).mod(filteredSuggestions.length)

