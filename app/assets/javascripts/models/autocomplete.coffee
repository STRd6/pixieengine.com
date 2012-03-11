namespace "Pixie.Models", (Models) ->
  class Models.Autocomplete extends Backbone.Model
    defaults:
      suggestions: ["$", "_", "pixieCanvas", "times", "first", "last", "each", "map", "indexOf", "includes"]
      selectedOption: 0

    decrementSelected: =>
      @_shiftSelected(-1)

    filteredSuggestions: (currentToken) =>
      {suggestions} = @attributes
      loweredToken = currentToken.toLowerCase()

      return suggestions.map (suggestion) ->
        loweredSuggestion = suggestion.toLowerCase()

        suggestion unless loweredSuggestion.indexOf(loweredToken) is -1

    incrementSelected: =>
      @_shiftSelected(+1)

    _shiftSelected: (value) =>
      {editor, selectedOption} = @attributes

      cursorPosition = editor.getCursor()

      currentToken = editor.getTokenAt(editor.coordsChar(cursorPosition)).string

      @set
        selectedOption: (selectedOption + value).mod(@filteredSuggestions(currentToken).length)

