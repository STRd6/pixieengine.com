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

    # TODO fix autocomplete bug where going to a previous token doesn't filter propertly eg.
    # `engine.start()` Right now, placing your cursor after engine. causes it to filter based on the token 'start'.
    # The solution is to only use the substring between the start of the token (maybe +1 because of the period)
    # and the cursor position. I think this should be usable across the board in the filter function.
    filterSuggestions: =>
      {editor, suggestions} = @attributes

      cursorPosition = editor.getCursor()
      currentToken = editor.getTokenAt(cursorPosition)
      line = cursorPosition.line

      currentString = editor.getRange({line: line, ch: currentToken.start}, {line: line, ch: cursorPosition.ch}).replace(/[^\w]/g, '')

      if currentString is ''
        @set
          filteredSuggestions: suggestions.copy().sort()

        return currentString

      matches = suggestions.map (suggestion) ->
        suggestion if suggestion.indexOf(currentString) is 0

      if matches.compact().length
        @set
          filteredSuggestions: matches.compact().sort()
      else
        @set
          filteredSuggestions: suggestions.copy().sort()

      return currentString

    incrementSelected: =>
      @_shiftSelected(+1)

    _shiftSelected: (value) =>
      {editor, filteredSuggestions, selectedIndex} = @attributes

      cursorPosition = editor.getCursor()

      currentToken = editor.getTokenAt(editor.coordsChar(cursorPosition)).string

      @set
        selectedIndex: (selectedIndex + value).mod(filteredSuggestions.length)

