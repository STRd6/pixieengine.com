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

  # Make sure that the editor doesn't get stuck at a small size by popping in too fast
  setTimeout ->
    editor.refresh()
  , 100

  $editor = $(editor)

  # Listen for keypresses and update contents.
  processEditorChanges = ->
    currentCode = editor.getCode()

    if currentCode isnt savedCode
      $editor.trigger('dirty')
    else
      $editor.trigger('clean')

    textArea.value = currentCode

  $editor.bind "save", ->
    codeToSave = editor.getCode()

    file.set
      contents: codeToSave

    saveFile
      contents: codeToSave
      path: path
      success: ->
        # Editor's state may have changed during ajax call
        if editor.getCode() is codeToSave
          $editor.trigger "clean"
        else
          $editor.trigger "dirty"

        savedCode = codeToSave

  return $editor
