window.codeEditor = ({panel, code:savedCode, save}) ->
  editor = ace.edit(panel.get(0))
  editor.setValue savedCode
  editor.setTheme("ace/theme/twilight")
  editor.getSession().setMode("ace/mode/coffee")
  editor.setDisplayIndentGuides(true)
  editor.clearSelection()

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

      hotSwap(savedCode, file.name().extension())

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
