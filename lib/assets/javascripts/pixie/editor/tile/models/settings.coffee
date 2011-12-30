# require ./selection

namespace "Pixie.Editor.Tile.Models", (Models) ->

  class Models.Settings extends Backbone.Model
    defaults:
      title: ""
      tilesWide: 20
      tilesTall: 15
      tileWidth: 32
      tileHeight: 32

    initialize: ->
      @commandStack = CommandStack()
      @execute = @commandStack.execute

      @selection = new Models.Selection

    undo: ->
      @commandStack.undo()

    redo: ->
      @commandStack.redo()

    pixelWidth: =>
      @get("tilesWide") * @get("tileWidth")

    pixelHeight: =>
      @get("tilesTall") * @get("tileHeight")

    toJSON: ->
      width: @get "tilesWide"
      height: @get "tilesTall"
      tileWidth: @get "tileWidth"
      tileHeight: @get "tileHeight"
      title: @get "title"
