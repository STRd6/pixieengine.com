#= require tmpls/pixie/editor/tile/editor

#= require pixie/editor/base
#= require pixie/editor/undo
#= require pixie/view

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

      #TODO Allow external entities list to be passed in as options
      @entityList = new Models.EntityList [
        new Models.Entity
          src: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAABHUlEQVRYR+2WwQ3CMAxFW3HkxjzMgZgAMQUHpkBMgDoH83DjiEA+BJlg/3y7SBVSeyQl7+U7Tdx3Ez/9xPzuvwW21/uzJHhZL1OLCf9JQ73yRWQoAQZqyTAiTYEsnC2NKzAWrBNBSXwJMODheHO/3s1hZY55EmEBBNdkS8SS+BBAq2fBUQlKIAMvInUSdQqjBB6n3XvBi/3ZrH2rFE0Bb/UaXsishE4BCkTgSAKlMAukEpC4rT0gv1v7IF0CmZDdB94GlDloAXm5PozQGSApIHALLuPUUZw9iJh7gRJApfBuJQZuJmCVQUOYNDy4zAOPYg2KXssIipoT2BExEm5jUA3Q/YA3YUbmJz2hJeTJMMB6vmZTykacfW8WmBN4AS/7qCEFLkXAAAAAAElFTkSuQmCC"
        new Models.Entity
          src: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA5klEQVRYR2NkGGDAOMD2M4w6YDQERkOA6BD4NpXjP7WyLFf2D7i9RDkAZPnh2/8Y9H0rGS5ubieLBjme70Yn2A8kOQDZckpCAGQ5yBO2qkzEO4DaloNCEOQQokKAFpbDooGgA6iZ4GBpB2Q5KP0QFQUgB3zSKCc7wcESKizeQUEPA0RFAcwBlCQ6WHCDPAIDJIUActCR65DREBgNgdEQGA2BQRUC2EpBUAGHtUFCi5oQvQ6Ala44HYBchlNaFKPXgMjmEQwBcptgsCBHb4KhewanA8j1Nbo+5MYHNjOJapRSyzGD0gEAm/Y7MAMUHQMAAAAASUVORK5CYII="
      ]

      @settings = new Models.Settings
        activeLayer: @layerList.at(0)
        activeEntity: @entityList.at(0)

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

      @render()

      @takeFocus()

    render: =>
      return this

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
      @entityList.reset()

      $.each data.entityCache, (uuid, object) =>
        entity = new Models.Entity
          uuid: uuid
          src: object.src
          properties: object.properties

        entityLookup[uuid] = entity
        @entityList.add entity

      @layerList.reset()
      data.layers.each (layerData, i) =>
        layer = new Models.Layer _.extend({zIndex: i}, layerData)

        layerData.instances.each (instanceData) =>
          instance = new Models.Instance
            x: instanceData.x
            y: instanceData.y
            sourceEntity: entityLookup[instanceData.uuid]
            properties: instanceData.properties

          layer.addObjectInstance instance

        @layerList.add(layer)

      #TODO: Activate correct layer and entity

   takeFocus: ->
     super()

    events:
      mousemove: "takeFocus"
