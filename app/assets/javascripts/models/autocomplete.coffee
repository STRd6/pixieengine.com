namespace "Pixie.Models", (Models) ->
  class Models.Autocomplete extends Backbone.Model
    defaults:
      suggestions: ["$", "_", "pixieCanvas", "times", "timer", "time",  "first", "last", "each", "map", "indexOf", "includes"]
      filteredSuggestions: ["$", "_", "pixieCanvas", "times", "timer", "time", "first", "last", "each", "map", "indexOf", "includes"]
      selectedIndex: 0

    getCurrentToken: =>
      {editor} = @attributes

      cursorPosition = editor.getCursor()

      return editor.getTokenAt(cursorPosition).string.replace('.', '')

    currentSuggestion: =>
      @get('filteredSuggestions')[@get('selectedIndex')]

    decrementSelected: =>
      @_shiftSelected(-1)

    filterSuggestions: (currentToken) =>
      {editor, suggestions} = @attributes

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

      # ghosting currently selected suggestion
      #currentSuggestion = @currentSuggestion()

      #if currentSuggestion
      #  cursorPosition = editor.getCursor()

      #  editor.replaceRange(currentSuggestion.substring(currentToken.length - 1), cursorPosition)

      #  cursorPosition = editor.getCursor()

      #  editor.setSelection(
      #    line: cursorPosition.line
      #    ch: cursorPosition.ch - (currentSuggestion.length - currentToken.length)
      #  , cursorPosition)
      # end ghosting

      return currentToken

    incrementSelected: =>
      @_shiftSelected(+1)

    _shiftSelected: (value) =>
      {editor, filteredSuggestions, selectedIndex} = @attributes

      cursorPosition = editor.getCursor()

      currentToken = editor.getTokenAt(editor.coordsChar(cursorPosition)).string

      @set
        selectedIndex: (selectedIndex + value).mod(filteredSuggestions.length)

