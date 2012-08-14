window.codeEditor = ({panel, code:savedCode, save}) ->
  # disable the worker stuff until ace fixes it
  require("ace/edit_session").EditSession.prototype.$startWorker = -> ;

  editor = ace.edit(panel.get(0))

  editor.setValue savedCode
  editor.setTheme "ace/theme/twilight"

  Mode = require("ace/mode/coffee").Mode

  editor.getSession().setMode(new Mode())

  editor.clearSelection()

  editor.setDisplayIndentGuides true
  editor.renderer.setShowPrintMargin false
  editor.getSession().setTabSize 2
  editor.getSession().setUseSoftTabs true
  editor.getSession().setUseWrapMode true

  # fixes bug where newly opened editor is blank
  editor.addEventListener 'focus', ->
    editor.resize()

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
