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
        @$('li').eq(selectedOption).takeClass('selected').get(0).scrollIntoView(false)

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

    _insertSuggestion: (suggestion) =>
      cursorPosition = @editor.getCursor()

      @editor.replaceRange(suggestion, cursorPosition)

      @hide()

    returnSuggestion: =>
      autocompleteValue = @$('li.selected').text()

      @_insertSuggestion(autocompleteValue)

    render: =>
      @$('li').remove()

      {selectedOption, suggestions} = @model.attributes

      for suggestion in suggestions.sort()
        $(@el).append "<li>#{suggestion}</li>"

      @$('li').eq(selectedOption).takeClass('selected').get(0).scrollIntoView(false)

      $(@el).css
        left: @currentPosition.x
        top: @currentPosition.yBot

      return @

    show: =>
      @currentPosition = @editor.cursorCoords()

      $(@render().el).show()
