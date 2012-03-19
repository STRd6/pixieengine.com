$ ->
  window.entities = new Pixie.Editor.Tile.Models.EntityList()

  # Populate initial entities
  tree.flatten().each (file) ->
    return unless file.get("extension") is "entity"

    entityData = file.get("contents").parse()

    # TODO: Make sure entities get created with uuids to prevent
    # collisions from multiple people making the same file name
    # and importing/merging projects
    #
    # In the meantime just treat the file name as the uuid
    # because within a single project the file name must be
    # unique
    entityData.uuid ||= file.get("name")

    window.entities.add entityData

window.createTilemapEditor = (options, file) ->
  {path, contents} = file.attributes
  panel = options.panel

  panel.find('.tile_editor, .pixie').remove()

  try
    data = JSON.parse(contents)
  catch e
    ;

  editorOptions = $.extend panel.data("options"),
    data: data

    editEntity: (entity) ->
      # Assume uuid is file name
      if entityFile = tree.getFile(entity.get('uuid')).filter (file) ->
        file.get("extension") is "entity"
      .first()
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

      if title
        filePath = projectConfig.directories.tilemaps

        extension = "tilemap"
        dataString = JSON.stringify(tileEditor)

        newFileNode
          name: title
          type: "tilemap"
          extension: extension
          path: filePath
          contents: dataString

        saveFile
          contents: dataString
          path: filePath + "/" + title + "." + extension
          success: ->
            ;# TODO: Maybe close this one and open the saved as one

  tileEditor.el.appendTo(panel)

  return tileEditor
