createCodeMirrorEditor = (textArea) ->
  code = textArea.val()
  lang = "coffeescript"

  editor = new CodeMirror.fromTextArea textArea.get(0),
    autoMatchParens: true
    content: code
    height: "100%"
    lineNumbers: true
    parserfile: ["tokenize_" + lang + ".js", "parse_" + lang + ".js"]
    path: "/assets/codemirror/"
    stylesheet: ["/assets/codemirror/main.css"]
    tabMode: "shift"
    textWrapping: false

  $(editor.win.document).find('html').toggleClass('light', $(".bulb-sprite").hasClass('static-on'))

  $(editor.win.document).keyup ->
    textArea.val(editor.getCode())

window.createEntityEditor = (options) ->
  {panel, uuid, path} = options

  panel.find('form').hide()
  panel.find('.editor').remove()

  defaults =
    color: '#0000FF'
    height: 32
    width: 32
    sprite: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAEzElEQVRYCbWXXYhVVRTH153EbKaZ0RjKRKdrM9NDfqCNFGbJpA8NmBQoJhOEbxH6ECR4lR7DxvLBh8KHXiwoNSiycWAqtIlKERqD0AL7oKYwqalp5tZUEp7Ob5/577vPmXMu89KCe/bea62z/v+91v44txRFkd3x6u+RxbK0pcHefaSlRP//lAffnnR4YMwRUGXNDdY2r2Qy5hE5UDrgX9R7Ybsn2lOXvGLvXDnPvbb74ylroHfp8fml/k//srG/I8PIT84CALy9p90Ni9p6BImn2OAADq7PAJGvTF2Lnw0uEyJBJgQ+OjxqgKvd9OKtsT8/s8Fd5vRuEDw0EeIBjCQ4iZPLAF3YHPniH2eUIy9pfSTutSfgc5rb7P29v9qFt+ZaQqZmBzg7a6yAgwMe41QGUEggwZo4eF+jfSllpv23OmZbB7Za9E5kkxeHnRXCLGbIS4ilWYfg2H0GGIRZYFxPmD3S3d1tpVJt7UFY4ACH4NWxKzNCFmYgXA8z3ooVZz760O5etcxOv3IwZQYwFM0c8Dd/XuBTL59cAgsbG3zKsgH1IuCIMkE5kK9GL1tz20LX16MIHHuqBCgoA1syJIE+K1e7H/YqwAd3/eTHSrVab8jpzCCQ45OrmjtywukBP7z8XK4Pynqzx15IgNrVy4JST5BQyudf9kNKkVd37xB3CgngJBLhC+qr5owfO7tcatu0YZ1BYjbp56VcAtqOnecO2S/LDqVOP48Ud5SFluYmr76uab4jsfqbY6kDxztkOrkE8Hm2etge2rw5454+bskCJEQE59bWVoPEbCWXwBsvPRcBDkB49usOUHABNx1dYX29fU792+XvHYn71693k5BvUVvieyCUEHyy+qe9tvaCDb0+5F16+3pdv9JfcW1Pe4+3DY8Om8XHwcSOD3xWTg4M2Lade2tHpfdOOqmDKAt+ZuRzq+zeF+c9cQYMMg4oVglc40zsWQ19CfLAU8ynzAF7sHim9P04thdJ0Y2KvyMAeG/PWldz0s7MBR69EJVIqzUG4RlzF9FKsMfjysZvbWj4rIslU73WZ0ALCvCsdK0YT8AAFDhOIjGtBzy8B3RWbLl5vPC7whMgHiTIxL3dK42soCN9BHACYHILJ2OegQ5wzo687bvjzus9CWIrvt8FUmj7qRRf3/OUO9X6T90+E7xGw47fuN+N9D4DSvFZx3aXFY51Lrmnf3zeHVTYybbfBao5RMiCTjeO1FzwoBSAk7WbFt3may/wrvZFYLmvK1qOamJjBzNVAhxQYlQAdMfLyexSiy5Tiiz4M81PGuB81vFD+PTfcGmdHT3xnl/kvgTOI35Qc+rFzDnPkUe/i8+CWDhgWo88kJQiyADEPMlp/x+2nHRgfKIh+jTLfhOmCGTBKQUCKODq03oycf/8xmN216ntqJ0ArhKuGVnlZq5PMxxCEr4EeeDamgJPwifg6gPe1bHUEZKfwFnIXGosviJxBASe5yQSsgmE4KS9Y8ktdu3qlD/7Q7sONF3vzDwrfhfUjAts9bSXrlu9BCgyePoTm6j+YeXFyb8i2dVqC2tnoYcELZNViy61BjBI2I6d5SXWWV5sCjg+UXXmJ/bt97db6IdRviG4Yua1hQRw1uFEv17A0A9fpJ5/4pE8/wNWTcdXfsfTiwAAAABJRU5ErkJggg=='

  try
    data = JSON.parse(panel.find("[name=contents]").val()) || defaults
  catch e
    console?.warn? e
    data = defaults

  editorOptions = $.extend panel.data("options"),
    data: data

  entityEditor = $("#entity_editor_template").tmpl().appendTo(panel)

  entityEditor.find(".events").accordion
    collapsible: true

  entityEditor.find(".events .event textarea").each ->
    input = $(this)
    name = input.attr("name")

    input.val(data[name + "Coffee"])

    createCodeMirrorEditor(input)

  propertyEditor = entityEditor.find('table').propertyEditor(data)

  entityEditor.bind 'save', ->
    entityData = propertyEditor.getProps()

    entityEditor.find(".events .event textarea").each ->
      input = $(this)
      name = input.attr("name")

      if name
        source = input.val()

        # Merge in events data
        entityData[name + "Coffee"] = source
        entityData[name] = window.compileCode source, "coffee"

    # Propagate changes back to IDE
    window.entities[uuid] = entityData

    dataString = JSON.stringify(entityData)

    panel.find("[name=contents]").val(dataString)

    saveFile
      contents: dataString
      path: path
      success: ->
        entityEditor.trigger "clean"

  return entityEditor
