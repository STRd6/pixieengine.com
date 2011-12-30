namespace "Pixie.Editor.Tile.Models", (Models) ->

  class Models.Selection extends Backbone.Model
    defaults:
      startX: 0
      startY: 0
      x: 0
      y: 0
      width: 0
      height: 0
      active: false
