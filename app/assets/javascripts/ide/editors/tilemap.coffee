window.createTilemapEditor = (options, file) ->
  {path, contents, options:editorOptions} = file.attributes
  panel = options.panel

  panel.find('.tile_editor, .pixie').remove()

  data = null

  try
    data = JSON.parse(contents) if contents
  catch e
    console?.warn? e
    console?.warn? "Occurred in #{contents}"

  editorOptions = Object.extend editorOptions,
    data: data

    editEntity: (entity) ->
      # Assume uuid is file name
      entitiesDir = projectConfig.directories.entities || 'entities'

      if entityFile = tree.getFile("#{entitiesDir}/#{entity.get('uuid')}.entity")
        openFile(entityFile)

    newEntity: ->
      newFileModal()
      setTimeout ->
        $("#new_file_modal button:contains(Entity)").click()
      , 15

    entityList: window.entities

  tileEditor = new Pixie.Editor.Tile.Views.Editor(editorOptions)

  saveAction = ->
    dataString = JSON.stringify(tileEditor)

    file.set
      contents: dataString

    saveFile
      contents: dataString
      path: path

    tileEditor.trigger 'clean'

  tileEditor.bind 'save', saveAction

  tileEditor.addAction
    name: 'Save'
    # Don't need hotkeys because the IDE ctrl+s triggers the save event
    perform: (editor) ->
      saveAction()

  tileEditor.addAction
    name: "Save As"
    perform: ->
      oldFile = tree.getFile(path)

      [fileNames..., extension] = oldFile.name().split('.')

      title = prompt("Title", fileNames.join('.'))

      if title
        filePath = projectConfig.directories.tilemaps

        extension = "tilemap"
        dataString = JSON.stringify(tileEditor)
        fullPath = "#{filePath}/#{title}.#{extension}"

        newFileNode
          autoOpen: true
          type: "tilemap"
          path: fullPath
          contents: dataString

        closeFile oldFile

        saveFile
          contents: dataString
          path: fullPath
          success: ->
            ;

  tileEditor.el.appendTo(panel)

  return tileEditor
