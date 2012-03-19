window.createTextEditor = (options, file) ->
  panel = options.panel
  {contents, id, language, path} = file.attributes

  savedCode = file.get 'contents'

  if language is "html"
    language = "xml"

  language ||= "dummy"

  autocompleteIndex = 0

  autocompleteModel = new Pixie.Models.Autocomplete
  autocomplete = new Pixie.Views.Autocomplete
    model: autocompleteModel

  unless $('.code_autocomplete').length
    $(autocomplete.render().el).appendTo $('body')

  editor = CodeMirror panel.get(0),
    autoMatchParens: true
    value: savedCode
    lineNumbers: true
    tabMode: "shift"
    textWrapping: false
    onKeyEvent: (editor, e) ->
      if e.type is "keydown"
        cursorPosition = editor.getCursor()
        line = cursorPosition.line

        if e.ctrlKey and e.keyCode is 32
          filteredSuggestions = autocompleteModel.get('filteredSuggestions')

          if filteredSuggestions.length is 1
            autocomplete._insertSuggestion(filteredSuggestions.first())
          else
            autocomplete.show()

        # hide the autocomplete dialog by pressing escape
        if e.keyCode is 27 or e.keyCode is 37
          e.preventDefault()

          autocomplete.hide()

        if $(autocomplete.el).is(':visible')
          # update the autocomplete dialog by pressing up and down
          if e.keyCode is 40
            e.preventDefault()

            autocompleteModel.incrementSelected()

            return true

          else if e.keyCode is 38
            e.preventDefault()

            autocompleteModel.decrementSelected()

            return true

          # enter the autocomplete value
          if e.keyCode is 13 or e.keyCode is 9 or e.keyCode is 39
            e.preventDefault()

            autocomplete.returnSuggestion()

            return true

        return false

      if e.type is "keyup"
        autocompleteModel.filterSuggestions()
        autocomplete.render()

        if e.keyCode is 190
          autocomplete.show()

        processEditorChanges()

        return undefined

  autocomplete.editor = editor
  autocompleteModel.set
    editor: editor

  # Make sure that the editor doesn't get stuck at a small size by popping in too fast
  setTimeout ->
    editor.refresh(); editor.refresh() # Double refresh fixes the missing lines after 100
    editor.focus() # we also want to focus the editor
  , 100

  $editor = $(editor)

  # Listen for keypresses and update contents.
  processEditorChanges = ->
    currentCode = editor.getValue()

    if currentCode is savedCode
      $editor.trigger('clean')
    else
      $editor.trigger('dirty')

  $editor.bind "save", ->
    codeToSave = editor.getValue()

    file.set
      contents: codeToSave

    saveFile
      contents: codeToSave
      path: path
      success: ->
        # Editor's state may have changed during ajax call
        if editor.getValue() is codeToSave
          $editor.trigger "clean"
        else
          $editor.trigger "dirty"

        savedCode = codeToSave

  return $editor
