#= require tmpls/ide/editors/json.js.tmpl.haml

window.createJsonEditor = (options, file) ->
  {panel} = options
  {contents, path} = file.attributes

  # See if this is the special config file
  projectConfig = path is "pixie.json"

  panel.find('form').hide()
  panel.find('.editor').remove()

  try
    data = JSON.parse(contents) || {}
  catch e
    console?.warn? e
    data = {}

  jsonEditor = $.tmpl("tmpls/ide/editors/json").appendTo(panel)

  propertyEditor = jsonEditor.find('table').propertyEditor(data)

  jsonEditor.bind 'save', ->
    jsonData = propertyEditor.getProps()

    dataString = JSON.stringify(jsonData)

    file.set
      contents: dataString

    saveFile
      contents: dataString
      path: path
      success: ->
        jsonEditor.trigger "clean"

    # Propagate changes back to IDE
    if projectConfig
      window.loadProjectConfig()

  return jsonEditor
