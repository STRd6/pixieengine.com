$ ->
  window.entities = new Pixie.Editor.Tile.Models.EntityList()

  # Populate initial entities
  $('ul.filetree [data-type=entity]').each ->
    $this = $(this)
    fileNode = $this.prev()

    uuid = fileNode.text().replace(/\.[^\.]*$/, '')
    entityData = $this.find("[name=contents]").text().parse()

    entityData.uuid = uuid

    if name = entityData.name
      fileNode.text(name)
      $this.attr('data-name', name)
      $this.attr('data-uuid', uuid)

    window.entities.add entityData

  # Bind a listener for new entities to create entity files
  entities.bind "add", (entity) ->
    uuid = entity.get "uuid"
    displayName = entity.get("name") || uuid

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

    notify("Added #{displayName} into entities.")

window.createTileEditor = (options) ->
  panel = options.panel

  panel.find('form').hide()
  panel.find('.tile_editor, .pixie').remove()

  try
    data = JSON.parse(panel.find("[name=contents]").val())
  catch e
    ;

  editorOptions = $.extend panel.data("options"),
    data: data

    editEntity: (uuid) ->
      $("ul.filetree [title=#{uuid}] span").click()

    entityList: window.entities

  tileEditor = new Pixie.Editor.Tile.Views.Editor(editorOptions)

  tileEditor.addAction
    name: 'Save'
    hotkeys: "ctrl+s"
    perform: (editor) ->
      dataString = JSON.stringify(editor)

      panel.find("[name=contents]").val(dataString)

      saveFile
        contents: dataString
        path: options.path
        success: ->
          editor.trigger('clean')

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

  tileEditor.el.appendTo(panel)

  return tileEditor
