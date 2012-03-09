window.createTextEditor = (options, file) ->
  panel = options.panel
  {contents, id, language, path} = file.attributes

  panel.append "<textarea name='contents' style='display:none;'>#{contents}</textarea>"

  textArea = panel.find('textarea').get(0)
  savedCode = file.get 'contents'

  if language is "html"
    language = "xml"

  language ||= "dummy"

  editor = new CodeMirror.fromTextArea textArea,
    autoMatchParens: true
    content: savedCode
    lineNumbers: true
    tabMode: "shift"
    textWrapping: false
    onKeyEvent: (editor, e) ->
      if e.type == "keyup"
        processEditorChanges()

        return undefined

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
