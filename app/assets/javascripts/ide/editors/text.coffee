window.createTextEditor = (options, file) ->
  panel = options.panel
  {contents, id, language, path} = file.attributes

  savedCode = file.get 'contents'

  if language is "html"
    language = "xml"

  language ||= "dummy"

  editor = CodeMirror panel.get(0),
    autoMatchParens: true
    value: savedCode
    lineNumbers: true
    tabMode: "shift"
    textWrapping: false
    onKeyEvent: (editor, e) ->
      if e.type == "keyup"
        processEditorChanges()

        return undefined

  # Make sure that the editor doesn't get stuck at a small size by popping in too fast
  setTimeout ->
    editor.refresh(); editor.refresh() # Double refresh fixes the missing lines after 100
    editor.focus() # we also want to focus the editor
  , 0

  $editor = $(editor)

  # HACK: This is so that the editor can be focused when the tab is clicked
  panel.data textEditor: editor

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
