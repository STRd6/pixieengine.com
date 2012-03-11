namespace "Pixie.Models", (Models) ->
  class Models.Autocomplete extends Backbone.Model
    defaults:
      suggestions: ["$", "_", "pixieCanvas", "times", "timer", "time",  "first", "last", "each", "map", "indexOf", "includes"]
      filteredSuggestions: ["$", "_", "pixieCanvas", "times", "timer", "time", "first", "last", "each", "map", "indexOf", "includes"]
      selectedOption: 0

    decrementSelected: =>
      @_shiftSelected(-1)

    filterSuggestions: (currentToken) =>
      {suggestions} = @attributes

      return suggestions.sort() if currentToken is '.'

      currentToken = currentToken.replace('.', '')

      matches = suggestions.map (suggestion) ->
        suggestion if suggestion.indexOf(currentToken) is 0

      @set
        filteredSuggestions: matches.compact().sort()

    incrementSelected: =>
      @_shiftSelected(+1)

    _shiftSelected: (value) =>
      {editor, filteredSuggestions, selectedOption} = @attributes

      cursorPosition = editor.getCursor()

      currentToken = editor.getTokenAt(editor.coordsChar(cursorPosition)).string

      @set
        selectedOption: (selectedOption + value).mod(filteredSuggestions.length)

