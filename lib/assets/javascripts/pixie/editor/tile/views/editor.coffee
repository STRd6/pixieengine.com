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
      @entityList = @options.entityList

      @settings = new Models.Settings

      @resetActiveObjects()

      # Add Sub-components
      screen = new Views.Screen
        collection: @layerList
        editor: this
        settings: @settings
      @$(".content").prepend screen.el

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
        hotkeys: "del"
        perform: (editor) ->
          editor.deleteSelection()

      # Set Eval Context
      @eval = (code) =>
        eval(code)

      @include Tile.Console

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

    toJSON: ->
      settingsJSON = @settings.toJSON()

      #TODO: Prune unused entities out of entity cache

      return Object.extend settingsJSON,
        entityCache: @entityList.toJSON()
        layers: @layerList.toJSON()
        orientation: "orthogonal"

    fromJSON: (data) ->
      @settings.set
        title: data.title
        width: data.tilesWide
        height: data.tilesTall
        tileWidth: data.tileWidth
        tileHeight: data.tileHeight

      entityLookup = {}

      $.each data.entityCache, (uuid, object) =>
        if entity = @entityList.findByUUID(uuid)
          # Just add it to cache, entity list already has the entity
          entityLookup[uuid] = entity
        else
          # Add the entity from the map to the list
          entity = new Models.Entity
            uuid: uuid
            sprite: object.sprite
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
        else
          ; #TODO Handle non-instance layers

        @layerList.add(layer)

      @resetActiveObjects()

   takeFocus: ->
     super()

    events:
      mousemove: "takeFocus"
