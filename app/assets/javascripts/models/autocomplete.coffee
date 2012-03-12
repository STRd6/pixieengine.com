namespace "Pixie.Models", (Models) ->
  class Models.Autocomplete extends Backbone.Model
    defaults:
      suggestions: ["$", "_", "pixieCanvas", "times", "timer", "time",  "first", "last", "each", "map", "indexOf", "includes"]
      filteredSuggestions: ["$", "_", "pixieCanvas", "times", "timer", "time", "first", "last", "each", "map", "indexOf", "includes"]
      selectedOption: 0

    getCurrentToken: =>
      {editor} = @attributes

      cursorPosition = editor.getCursor()

      return editor.getTokenAt(cursorPosition).string.replace('.', '')

    decrementSelected: =>
      @_shiftSelected(-1)

    filterSuggestions: (currentToken) =>
      {suggestions} = @attributes

      if currentToken is '.'
        @set
          filteredSuggestions: suggestions.sort()

      currentToken = currentToken.replace('.', '')

      matches = suggestions.map (suggestion) ->
        suggestion if suggestion.indexOf(currentToken) is 0

      if matches.length
        @set
          filteredSuggestions: matches.compact().sort()
      else
        @set
          filteredSuggestions: suggestions.copy().sort()

    incrementSelected: =>
      @_shiftSelected(+1)

    _shiftSelected: (value) =>
      {editor, filteredSuggestions, selectedOption} = @attributes

      cursorPosition = editor.getCursor()

      currentToken = editor.getTokenAt(editor.coordsChar(cursorPosition)).string

      @set
        selectedOption: (selectedOption + value).mod(filteredSuggestions.length)

