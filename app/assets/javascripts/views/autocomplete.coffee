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

      if currentToken.string.length
        offset = 1
      else
        offset = 0

      @editor.setSelection({line: cursorPosition.line, ch: currentToken.start + offset}, {line: cursorPosition.line, ch: currentToken.end})

      @editor.replaceSelection('')
      @editor.replaceRange(suggestion, cursorPosition)

      @hide()

    returnSuggestion: =>
      autocompleteValue = @$('li.selected').text()

      @_insertSuggestion(autocompleteValue)

    render: =>
      if @editor
        @$('li').remove()

        {filteredSuggestions, selectedIndex, suggestions} = @model.attributes

        currentToken = @model.getCurrentToken()

        for suggestion in filteredSuggestions
          if suggestion.indexOf(currentToken) is 0
            $(@el).append "<li><b>#{currentToken}</b>#{suggestion.substring(currentToken.length)}</li>"
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

      @currentPosition = @editor.charCoords({line: cursorPosition.line, ch: currentToken.start + 1})

      @render()

      if @$('li').length
        $(@el).show()

