window.createTileEditor = (options) ->
  panel = options.panel

  panel.find('form').hide()
  panel.find('.tile_editor, .pixie').remove()

  try
    data = JSON.parse(panel.find("[name=contents]").val())
  catch e

  editorOptions = $.extend panel.data("options"),
    data: data
    eachEntity: (fn) ->
      for uuid, entity of window.entities
        fn uuid, entity

    editEntity: (uuid) ->
      $("ul.filetree [title=#{uuid}] span").click()

    loadEntity: (uuid, tileData) ->
      if window.entities[uuid]
        # We have this one, use our version instead of the map's
        entity = tileData.entity = window.entities[uuid]
      else
        # We don't have this one, import it from the map entity cache
        entity = window.entities[uuid] = tileData.entity || {}

        displayName = entity.name || uuid
        dataString = JSON.stringify(entity)

        # Create entity file node
        filePath = projectConfig.directories["entities"]
        newNode = newFileNode
          name: uuid
          displayName: displayName
          type: "entity"
          ext: "entity"
          path: filePath
          contents: dataString
          noAutoOpen: true
          forceSave: true

        notify("Imported #{displayName} from map into entities.")

      # Lets the map get the updates if it wants
      return entity

    removeEntity: (uuid) ->
      console.log "TODO remove entity #{uuid}"
    save: ->
      tileEditor.trigger 'save'

  tileEditor = Pixie.Editor.Tile.create(editorOptions).appendTo(panel)

  tileEditor.addAction
    name: "Save As"
    perform: ->
      title = prompt("Title")

      if title
        filePath = projectConfig.directories["data"]

        extension = "tilemap"
        dataString = JSON.stringify(tileEditor.mapData())

        newFileNode
          name: title
          type: "tilemap"
          ext: extension
          path: filePath
          contents: dataString

        saveFile
          contents: dataString
          path: filePath + "/" + title + "." + extension
          success: ->
            ;# TODO: Maybe close this one and open the saved as one

  tileEditor.bind 'save', ->
    dataString = JSON.stringify(tileEditor.mapData())

    panel.find("[name=contents]").val(dataString)

    saveFile
      contents: dataString
      path: options.path
      success: ->
        tileEditor.trigger('clean')

  return tileEditor
