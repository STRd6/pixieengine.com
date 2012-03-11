window.createTextEditor = (options, file) ->
  panel = options.panel
  {contents, id, language, path} = file.attributes

  panel.append "<textarea name='contents' style='display:none;'>#{contents}</textarea>"

  textArea = panel.find('textarea').get(0)
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

  editor = new CodeMirror.fromTextArea textArea,
    autoMatchParens: true
    content: savedCode
    lineNumbers: true
    tabMode: "shift"
    textWrapping: false
    onKeyEvent: (editor, e) ->
      if e.type is "keydown"
        # remove the autocomplete dialog on pressing escape
        if e.keyCode is 27
          e.preventDefault()

          autocomplete.hide()

          return true

        if $(autocomplete.el).is(':visible')
          # update the autocomplete dialog on pressing up and down
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

      if e.type is "keyup"
        cursorPos = editor.cursorCoords()

        currentToken = editor.getTokenAt(editor.coordsChar(cursorPos)).string

        autocompleteModel.filteredSuggestions(currentToken)

        if (e.ctrlKey and e.keyCode is 32) or e.keyCode is 190
          autocomplete.show()

        processEditorChanges()

        return undefined

  autocomplete.editor = editor
  autocompleteModel.set
    editor: editor

  # Make sure that the editor doesn't get stuck at a small size by popping in too fast
  setTimeout ->
    editor.refresh()
  , 100

  $editor = $(editor)

  # Listen for keypresses and update contents.
  processEditorChanges = ->
    currentCode = editor.getValue()

    if currentCode is savedCode
      $editor.trigger('clean')
    else
      $editor.trigger('dirty')

    textArea.value = currentCode

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
