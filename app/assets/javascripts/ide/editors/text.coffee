window.codeEditor = ({panel, code:savedCode, save}) ->
  autocompleteModel = new Pixie.Models.Autocomplete
    text: savedCode

  autocomplete = new Pixie.Views.Autocomplete
    model: autocompleteModel

  if $('.code_autocomplete').length
    $('.code_autocomplete').remove()

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
            autocomplete.render()
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
  , 0

  $editor = $(editor)

  # Listen for keypresses and update contents.
  processEditorChanges = ->
    currentCode = editor.getValue()

    if currentCode is savedCode
      $editor.trigger('clean')
    else
      $editor.trigger('dirty')

  $editor.bind "save", ->
    savedCode = editor.getValue()

    $editor.trigger "clean"

    save(savedCode)

  return $editor

window.createTextEditor = (options, file) ->
  panel = options.panel
  {contents, id, path} = file.attributes

  $editor = codeEditor
    panel: panel
    code: contents
    save: (savedCode) ->
      #TODO: Local storage

      hotSwap(savedCode, file.get("extension"))

      file.set
        contents: savedCode

      saveFile
        contents: savedCode
        path: path
        success: -> # Assume always success

  editor = $editor.get(0)

  # HACK: This is so that the editor can be focused when the tab is clicked
  panel.data textEditor: editor

  return $editor
