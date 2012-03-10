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

  editor = new CodeMirror.fromTextArea textArea,
    autoMatchParens: true
    content: savedCode
    lineNumbers: true
    tabMode: "shift"
    textWrapping: false
    onKeyEvent: (editor, e) ->
      if e.type is "keydown"
        if $('.code_autocomplete').length and (e.keyCode is 13 or e.keyCode is 9)
          e.preventDefault()
          e.stopPropagation()

          cursorPosition = editor.getCursor()

          editor.replaceRange($('.code_autocomplete li.selected').text(), cursorPosition)

          # TODO use this to get previous token to pass into `getAutocompleteOptions`
          #editor.coordsChar(editor.cursorCoords())

          return false

      if e.type is "keyup"
        cursorPos = editor.cursorCoords()

        if e.ctrlKey and e.keyCode is 32
          $('.code_autocomplete').remove()
          autocompleteMenu = getAutocompleteOptions("someToken")
          autocompleteMenu.appendTo $('body')
          autocompleteMenu.css
            left: "#{cursorPos.x}px"
            top: "#{cursorPos.yBot}px"

          $('.code_autocomplete li').eq(autocompleteIndex).takeClass('selected')

        autocompleteChoices = $('.code_autocomplete li').length

        if e.keyCode is 40
          e.preventDefault()
          autocompleteIndex = (autocompleteIndex + 1) % autocompleteChoices
        else if e.keyCode is 38
          e.preventDefault()
          autocompleteIndex = (autocompleteIndex - 1).mod(autocompleteChoices)

        $('.code_autocomplete li').eq(autocompleteIndex).takeClass('selected')

        processEditorChanges()

        return undefined

  # Make sure that the editor doesn't get stuck at a small size by popping in too fast
  setTimeout ->
    editor.refresh()
  , 100

  $editor = $(editor)

  # document click event to close autocomplete menu
  $(document).click (e) ->
    $('.code_autocomplete').remove() unless $(e.target).is('.code_autocomplete')

  # TODO get real autocomplete list from CoffeeScript parse tree
  getAutocompleteOptions = (currentToken, context) ->
    return $ '<ul class=code_autocomplete><li>$</li><li>PixieCanvas</li><li>window</li></ul>'

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
