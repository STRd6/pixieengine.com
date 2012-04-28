namespace "Pixie.Views", (Views) ->
  class Views.Autocomplete extends Backbone.View
    className: 'code_autocomplete'
    tagName: 'ul'

    events:
      'click li': 'clickSuggestion'

    initialize: ->
      $(document).click (e) =>
        @hide() unless $(e.target).is('.code_autocomplete')

      @model.bind 'change:selectedIndex', (model, selectedIndex) =>
        @$('li').eq(selectedIndex).takeClass('selected')

      @currentPosition =
        x: 0
        y: 0
        yBot: 0

    clickSuggestion: (e) =>
      target = $(e.currentTarget)

      autocompleteValue = target.text()

      @_insertSuggestion(autocompleteValue)

    hide: =>
      @$el.hide()

      @model.set
        selectedIndex: 0

    _offset: (currentString) =>
      if currentString is '.'
        return 1
      else
        return 0

    _insertOnlySuggestion: =>
      suggestions = @model.filterSuggestions(context, currentString)

      @_insertSuggestion(suggestions.first())

    _insertSuggestion: (suggestion) =>
      cursorPosition = @editor.getCursor()
      currentToken = @editor.getTokenAt(cursorPosition)

      line = cursorPosition.line

      offset = @_offset(currentToken.string[0])

      if currentToken.string.replace(/[^\w]/g, '') is suggestion
        selectionEnd = currentToken.end
      else
        selectionEnd = cursorPosition.ch

      @editor.setSelection({line: line, ch: currentToken.start + offset}, {line: line, ch: selectionEnd})

      @editor.replaceSelection('')

      # need to get new cursor position since replacing
      # the selection has moved it
      @editor.replaceRange(suggestion, @editor.getCursor())

      @hide()

    returnSuggestion: =>
      autocompleteValue = @$('li.selected').text()

      @_insertSuggestion(autocompleteValue)

    render: =>
      if @editor
        @$('li').remove()

        {editor, selectedIndex} = @model.attributes

        cursorPosition = editor.getCursor()

        currentLine = editor.lineInfo(cursorPosition.line).text
        lastToken = currentLine.split(' ').last()

        [unusedTokens..., context, currentString] = lastToken.split('.')

        for suggestion in @model.filterSuggestions(context, currentString)
          if suggestion.indexOf(currentString) is 0 and currentString isnt ''
            suggestionEl = "<li><b>#{currentString}</b>#{suggestion.substring(currentString.length)}</li>"
          else
            suggestionEl = "<li>#{suggestion}</li>"

          @$el.append suggestionEl

        @$('li').eq(selectedIndex).takeClass('selected')

        if (selected = @$('li.selected')).length
          selected.get(0).scrollIntoView(false)

        @$el.css
          left: @currentPosition.x
          top: @currentPosition.yBot

      return @

    show: =>
      cursorPosition = @editor.getCursor()
      currentToken = @editor.getTokenAt(@editor.getCursor())

      offset = @_offset(currentToken.string[0])

      @currentPosition = @editor.charCoords({line: cursorPosition.line, ch: currentToken.start + offset})

      @$el.css
        left: @currentPosition.x
        top: @currentPosition.yBot

      @$el.show() if @$('li').length

