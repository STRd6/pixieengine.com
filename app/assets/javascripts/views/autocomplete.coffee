namespace "Pixie.Views", (Views) ->
  DOCS_LOOKUP =
    bind:
      object: 'Bindable'
      method: 'bind'
    bounds:
      object: 'Bounded'
      method: 'bounds'
    clamp:
      object: 'Clampable'
      method: 'clamp'
    clampToBounds:
      object: 'Clampable'
      method: 'clampToBounds'
    extend:
      object: 'Core'
      method: 'extend'
    flicker:
      object: 'Flickerable'
      method: 'flicker'
    include:
      object: 'Core'
      method: 'include'
    meter:
      object: 'Metered'
      method: 'meter'
    position:
      object: 'Bounded'
      method: 'position'
    tween:
      object: 'Tween'
      method: 'tween'
    unbind:
      object: 'Bindable'
      method: 'unbind'


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

    lineTokens: =>
      {editor} = @model.attributes

      cursorPosition = editor.getCursor()

      currentLine = editor.lineInfo(cursorPosition.line).text
      lastToken = currentLine.split(' ').last()

      lastToken.split('.')

    currentSuggestions: =>
      [unusedTokens..., context, currentString] = @lineTokens()

      @model.filterSuggestions(context, currentString)

    render: =>
      if @editor
        @$('li').remove()

        {selectedIndex} = @model.attributes

        currentString = @lineTokens().last()

        for suggestion in @currentSuggestions()
          docObject = DOCS_LOOKUP[suggestion]?.object
          docMethod = DOCS_LOOKUP[suggestion]?.method

          if suggestion.indexOf(currentString) is 0 and currentString isnt ''
            if docObject
              suggestionEl = "<li><a href='#{docUrl(docObject, docMethod)}' target=_blank><b>#{currentString}</b>#{suggestion.substring(currentString.length)}</a></li>"
            else
              suggestionEl = "<li><b>#{currentString}</b>#{suggestion.substring(currentString.length)}</li>"
          else
            if docObject
              suggestionEl = "<li><a href='#{docUrl(docObject, docMethod)}' target=_blank>#{suggestion}</a></li>"
            else
              suggestionEl = "<li>#{suggestion}</li>"

          @$el.append suggestionEl

        @$('li').eq(selectedIndex).takeClass('selected')

        if (selected = @$('li.selected')).length
          selected.get(0).scrollIntoView(false)
        else
          @$el.hide()

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

