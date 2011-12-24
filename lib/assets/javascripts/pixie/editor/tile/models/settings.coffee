namespace "Pixie.Editor.Tile.Models", (exports) ->

  class exports.Settings extends Backbone.Model
    defaults:
      tilesWide: 20
      tilesTall: 15
      tileWidth: 32
      tileHeight: 32

    pixelWidth: =>
      @get("tilesWide") * @get("tileWidth")

    pixelHeight: =>
      @get("tilesTall") * @get("tileHeight")
