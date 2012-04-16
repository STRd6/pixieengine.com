window.codeEditor = ({panel, code:savedCode, save}) ->
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
