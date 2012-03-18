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
      $(@el).hide()

      @model.set
        selectedIndex: 0

    _insertSuggestion: (suggestion) =>
      cursorPosition = @editor.getCursor()
      currentToken = @editor.getTokenAt(cursorPosition)

      line = cursorPosition.line

      if currentToken.string[0] is '.'
        offset = 1
      else
        offset = 0

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

        {editor, filteredSuggestions, selectedIndex, suggestions} = @model.attributes

        cursorPosition = editor.getCursor()
        line = cursorPosition.line

        currentToken = editor.getTokenAt(cursorPosition)
        currentString = editor.getRange({line: line, ch: currentToken.ch}, {line: line, ch: cursorPosition.ch})

        for suggestion in filteredSuggestions
          if suggestion.indexOf(currentToken) is 0
            $(@el).append "<li><b>#{currentToken}</b>#{suggestion.substring(currentString.length)}</li>"
          else
            $(@el).append "<li>#{suggestion}</li>"

        @$('li').eq(selectedIndex).takeClass('selected')

        if (selected = @$('li.selected')).length
          selected.get(0).scrollIntoView(false)

        $(@el).css
          left: @currentPosition.x
          top: @currentPosition.yBot

      return @

    show: =>
      cursorPosition = @editor.getCursor()
      currentToken = @editor.getTokenAt(@editor.getCursor())

      if currentToken.string[0] is '.'
        offset = 1
      else
        offset = 0

      @currentPosition = @editor.charCoords({line: cursorPosition.line, ch: currentToken.start + offset})

      @render()

      if @$('li').length
        $(@el).show()

