window.createTextEditor = (options) ->
  {path, panel, lang} = options

  textArea = panel.find('textarea').get(0)
  savedCode = textArea.value

  if lang == "html"
    lang = "xml"

  lang ||= "dummy"

  editor = new CodeMirror.fromTextArea textArea,
    autoMatchParens: true
    content: savedCode
    height: "100%"
    lineNumbers: true
    parserfile: ["tokenize_" + lang + ".js", "parse_" + lang + ".js"]
    path: "/assets/codemirror/"
    stylesheet: ["/assets/codemirror/main.css"]
    tabMode: "shift"
    textWrapping: false

  $editor = $(editor)

  # Match the current theme
  $(editor.win.document).find('html').toggleClass('light', $(".bulb-sprite").hasClass('static-on'))

  # Bind all the page hotkeys to work when triggered from the editor iframe
  bindKeys(editor.win.document, hotKeys)

  # Listen for keypresses and update contents.
  processEditorChanges = ->
    currentCode = editor.getCode()

    if currentCode != savedCode
      $editor.trigger('dirty')
    else
      $editor.trigger('clean')

    textArea.value = currentCode

  $(editor.win.document).keyup processEditorChanges.debounce(100)

  $editor.bind "save", ->
    codeToSave = editor.getCode()

    # Strip trailing whitespace
    codeToSave = codeToSave.replace(/[ ]+(\n+)/g, "$1").replace(/[ ]+$/, '')

    # Propagate back the whitespace stripping
    editor.setCode(codeToSave)

    saveFile
      contents: codeToSave
      path: path
      success: ->
        # Editor's state may have changed during ajax call
        if editor.getCode() == codeToSave
          $editor.trigger "clean"
        else
          $editor.trigger "dirty"

        savedCode = codeToSave

  return $editor
