#= require tmpls/ide/editors/json

window.createJsonEditor = (options) ->
  {panel, path} = options

  # See if this is the special config file
  projectConfig = path == "pixie.json"

  panel.find('form').hide()
  panel.find('.editor').remove()

  try
    data = JSON.parse(panel.find("[name=contents]").val()) || {}
  catch e
    console?.warn? e
    data = {}

  jsonEditor = $.tmpl("ide/editors/json").appendTo(panel)

  propertyEditor = jsonEditor.find('table').propertyEditor(data)

  jsonEditor.bind 'save', ->
    jsonData = propertyEditor.getProps()

    dataString = JSON.stringify(jsonData)

    panel.find("[name=contents]").val(dataString)

    saveFile
      contents: dataString
      path: path
      success: ->
        jsonEditor.trigger "clean"

    # Propagate changes back to IDE
    if projectConfig
      window.loadProjectConfig()

  return jsonEditor
