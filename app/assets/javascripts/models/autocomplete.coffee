namespace "Pixie.Models", (Models) ->
  class Models.Autocomplete extends Backbone.Model
    defaults:
      suggestions: ["$", "_", "pixieCanvas", "times", "timer", "time",  "first", "last", "each", "map", "indexOf", "includes"]
      filteredSuggestions: ["$", "_", "pixieCanvas", "times", "timer", "time", "first", "last", "each", "map", "indexOf", "includes"]
      selectedIndex: 0

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

      currentToken = @getCurrentToken()

      currentToken = currentToken.replace(/[^\w]/g, '')

      debugger

      if currentToken is ''
        @set
          filteredSuggestions: suggestions.copy().sort()

        return currentToken

      matches = suggestions.map (suggestion) ->
        suggestion if suggestion.indexOf(currentToken) is 0

      if matches.compact().length
        @set
          filteredSuggestions: matches.compact().sort()
      else
        @set
          filteredSuggestions: suggestions.copy().sort()

      return currentToken

    incrementSelected: =>
      @_shiftSelected(+1)

    _shiftSelected: (value) =>
      {editor, filteredSuggestions, selectedIndex} = @attributes

      cursorPosition = editor.getCursor()

      currentToken = editor.getTokenAt(editor.coordsChar(cursorPosition)).string

      @set
        selectedIndex: (selectedIndex + value).mod(filteredSuggestions.length)

