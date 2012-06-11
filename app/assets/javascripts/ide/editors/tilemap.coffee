window.createTilemapEditor = (options, file) ->
  {path, contents, options:editorOptions} = file.attributes
  panel = options.panel

  panel.find('.tile_editor, .pixie').remove()

  try
    data = JSON.parse(contents)
  catch e
    ;

  editorOptions = $.extend editorOptions,
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
      title = prompt("Title")

      oldFile = tree.getFile(path)

      if title
        filePath = projectConfig.directories.tilemaps

        extension = "tilemap"
        dataString = JSON.stringify(tileEditor)
        fullPath = "#{filePath}/#{title}.#{extension}"

        newFileNode
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
