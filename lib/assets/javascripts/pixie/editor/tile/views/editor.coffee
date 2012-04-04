#= require tmpls/pixie/editor/tile/editor

#= require pixie/editor/base
#= require pixie/editor/undo
#= require pixie/view

#= require_tree ../models
#= require_tree ../views

#= require ../actions
#= require ../command
#= require ../console

namespace "Pixie.Editor.Tile.Views", (Views) ->
  {Tile} = Pixie.Editor
  {Command, Models} = Tile

  class Views.Editor extends Pixie.View
    className: 'editor tile_editor'

    template: "pixie/editor/tile/editor"

    initialize: ->
      super

      @layerList = new Models.LayerList [
        new Models.Layer
          name: "Background"
          zIndex: 0
        new Models.Layer
          name: "Entities"
          zIndex: 1
      ]

      # External entities list must be passed in as options
      @entityList = @options.entityList || new Models.EntityList([])

      @settings = new Models.Settings

      @settings.loadFromOptions @options

      @resetActiveObjects()

      # Add Sub-components
      @screen = new Views.Screen
        collection: @layerList
        editor: this
        settings: @settings
      @$(".content").prepend @screen.el

      layerSelection = new Views.LayerSelection
        collection: @layerList
        editor: this
        settings: @settings
      @$(".module.right").append layerSelection.el

      entitySelection = new Views.EntitySelection
        collection: @entityList
        editor: this
        settings: @settings
      @$(".module.right").append entitySelection.el

      toolbar = new Views.Toolbar
        editor: this
        settings: @settings
      @$(".module.left").append toolbar.el

      @include Pixie.Editor.Base
      @include Pixie.Editor.Undo

      $.each Tile.actions, (name, action) =>
        action.name ||= name

        @addAction action

      @addAction
        name: "delete selection"
        menu: false
        hotkeys: "del backspace"
        perform: (editor) ->
          editor.deleteSelection()

      @addAction
        name: "edit instance properties"
        menu: false
        hotkeys: "i"
        perform: (editor) ->
          editor.editInstanceProperties()

      # Set Eval Context
      @eval = (code) =>
        eval(code)

      @include Tile.Console

      # Initialize Properties Editor
      @propEditor = @$(".prop_editor").propertyEditor()
      # TODO: Figure out why this wasn't working in backbone events list
      @$("button.prop_save").click @saveInstanceProperties
      @$("button.prop_cancel").click @closeInstanceProperties

      # Load map data if it exists
      if @options.data
        @fromJSON @options.data

      @render()

      @takeFocus()

    render: =>
      return this

    resetActiveObjects: ->
      @settings.set
        activeLayer: @layerList.at(0)
        activeEntity: @entityList.at(0)

    deleteSelection: ->
      layer = @settings.get "activeLayer"

      compoundCommand = Command.CompoundCommand()

      @settings.selection.eachPosition (x, y) ->
        if instance = layer.instanceAt(x, y)

          compoundCommand.push Command.RemoveInstance
            instance: instance
            layer: layer
          , true

      @execute compoundCommand unless compoundCommand.empty()

    editInstanceProperties: =>
      if instance = @screen.instanceAtCursor()
        @propEditor.instance = instance

        # jQuery Deep Copy
        props = $.extend(true, {}, instance.get("properties"))

        @propEditor.setProps(props)
        @propEditor.parent().show()
        @propEditor.find('input.key').focus()

    saveInstanceProperties: =>
      if instance = @propEditor.instance
        instance.set("properties", @propEditor.getProps())
        @closeInstanceProperties()

        #TODO Make this a command that heeds undo so we won't need to manually trigger dirty state
        @trigger "dirty"

    closeInstanceProperties: =>
      @propEditor.parent().hide()
      @propEditor.instance = null

      @takeFocus()

    toJSON: ->
      settingsJSON = @settings.toJSON()

      #TODO: Prune unused entities out of entity cache

      return Object.extend settingsJSON,
        entityCache: @entityList.toJSON()
        layers: @layerList.toJSON()
        orientation: "orthogonal"

    fromJSON: (data) ->
      tileWidth = data.tileWidth
      tileHeight = data.tileHeight

      @settings.set
        title: data.title
        tilesWide: data.tilesWide || data.width
        tilesTall: data.tilesTall || data.height
        tileWidth: tileWidth
        tileHeight: tileHeight

      entityCache = data.entityCache
      # Backwards compatibility
      unless entityCache
        entityCache = {}

        # Old school data had tileset instead of entities cache
        if data.tileset
          srcUuidMap = {}

          @entityList.each (entity) ->
            srcUuidMap[entity.src()] = entity.get('uuid')

          $.each data.tileset, (index, object) ->
            # These tiles probably don't have UUIDs yet

            # First check for a matching sprite
            existingSpriteUuid = srcUuidMap[object.sprite || object.src]
            object.uuid ||= existingSpriteUuid

            # Generate a uuid if none found
            object.uuid ||= Math.uuid(32, 16)

            #TODO Maybe match/meld with an existing entity
            entityCache[object.uuid] = object

      entityLookup = {}

      $.each entityCache, (uuid, object) =>
        if entity = @entityList.findByUUID(uuid)
          # Just add it to cache, entity list already has the entity
          entityLookup[uuid] = entity
        else
          # Add the entity from the map to the list
          entity = new Models.Entity
            uuid: uuid
            sprite: object.sprite || object.src
            properties: object.properties

          entityLookup[uuid] = entity
          @entityList.add entity

      @layerList.reset()
      data.layers.each (layerData, i) =>
        layer = new Models.Layer _.extend({zIndex: i}, layerData)

        if layerData.instances
          layerData.instances.each (instanceData) =>
            instance = new Models.Instance
              x: instanceData.x
              y: instanceData.y
              sourceEntity: entityLookup[instanceData.uuid]
              properties: instanceData.properties

            layer.addObjectInstance instance
        else if tiles = layerData.tiles
          # Older maps used a tiles property
          tiles.each (row, y) ->
            row.each (index, x) ->
              if sourceEntity = data.tileset[index]
                instance = new Models.Instance
                  x: x * tileWidth
                  y: y * tileHeight
                  sourceEntity: entityLookup[sourceEntity.uuid]

                layer.addObjectInstance instance
        else
          ; #TODO Handle non-instance, non-tile layers

        @layerList.add(layer)

      @resetActiveObjects()

   takeFocus: ->
     super()

    events:
      mousemove: "takeFocus"
