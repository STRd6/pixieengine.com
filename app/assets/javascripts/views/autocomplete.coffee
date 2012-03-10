namespace "Pixie.Views", (Views) ->
  class Views.Autocomplete extends Backbone.View
    className: 'code_autocomplete'
    tagName: 'ul'

    events:
      'click li': 'clickSuggestion'

    clickSuggestion: (e) =>
      target = $(e.currentTarget)

      autocompleteValue = target.text()

      cursorPosition = editor.getCursor()

      @editor.replaceRange(autocompleteValue, cursorPosition)

    render: =>
      {suggestions} = @model.attributes

      for suggestion in suggestions
        $(@el).append "<li>#{suggestion}</li>"

      return @

