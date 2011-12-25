# require ./entity

namespace "Pixie.Editor.Tile.Models", (exports) ->

  class exports.EntityList extends Backbone.Collection
    model: exports.Entity
