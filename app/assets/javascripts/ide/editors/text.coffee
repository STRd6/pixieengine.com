window.createTextEditor = (options, file) ->
  panel = options.panel
  {contents, id, language, path} = file.attributes

  form =
    """
      <form accept-charset="UTF-8" action="/projects/#{id}/save_file.json" method="post">
        <input name="path" type="hidden" value="#{path}">
        <textarea name="contents" style="display:none;">#{contents}</textarea>
      </form>
    """

  panel.append(form)

  textArea = panel.find('textarea').get(0)
  savedCode = panel.find('textarea').value

  if language is "html"
    language = "xml"

  language ||= "dummy"

  editor = new CodeMirror.fromTextArea textArea,
    autoMatchParens: true
    content: savedCode
    height: "100%"
    lineNumbers: true
    parserfile: ["tokenize_" + language + ".js", "parse_" + language + ".js"]
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

    if currentCode isnt savedCode
      $editor.trigger('dirty')
    else
      $editor.trigger('clean')

    textArea.value = currentCode

  $(editor.win.document).keyup processEditorChanges.debounce(100)

  $editor.bind "save", ->
    codeToSave = editor.getCode()

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
