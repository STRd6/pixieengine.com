namespace "Pixie.Views", (Views) ->
  class Views.Autocomplete extends Backbone.View
    className: 'code_autocomplete'
    tagName: 'ul'

    events:
      'click li': 'clickSuggestion'

    initialize: ->
      $(document).click (e) =>
        @hide() unless $(e.target).is('.code_autocomplete')

      @model.bind 'change:selectedOption', (model, selectedOption) =>
        @$('li').eq(selectedOption).takeClass('selected')

        if (selected = @$('li.selected')).length
          selected.get(0).scrollIntoView(false)

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
        selectedOption: 0

    _insertSuggestion: (suggestion) =>
      cursorPosition = @editor.getCursor()
      currentToken = @editor.getTokenAt(cursorPosition).string.replace('.', '')

      # Selecting the current token in order to delete it before inserting
      # suggestion. There has to be a better way to do this.
      @editor.setSelection(
        line: cursorPosition.line
        ch: cursorPosition.ch - currentToken.length
      , cursorPosition)

      @editor.replaceSelection('')
      @editor.replaceRange(suggestion, cursorPosition)

      @hide()

    returnSuggestion: =>
      autocompleteValue = @$('li.selected').text()

      @_insertSuggestion(autocompleteValue)

    render: =>
      if @editor
        @$('li').remove()

        {selectedOption, suggestions} = @model.attributes

        currentToken = @model.getCurrentToken()

        for suggestion in @model.get('filteredSuggestions')
          $(@el).append "<li><b>#{currentToken}</b>#{suggestion.substring(currentToken.length)}</li>"

        @$('li').eq(selectedOption).takeClass('selected')

        if (selected = @$('li.selected')).length
          selected.get(0).scrollIntoView(false)

        $(@el).css
          left: @currentPosition.x
          top: @currentPosition.yBot

      return @

    show: =>
      currentToken = @model.getCurrentToken()

      cursorPosition = @editor.getCursor()
      cursorPosition.ch = cursorPosition.ch - currentToken.length

      @currentPosition = @editor.charCoords(cursorPosition)

      $(@el).show()

      @render()
