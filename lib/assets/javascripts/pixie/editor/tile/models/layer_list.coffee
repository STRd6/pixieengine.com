# require ./layer

namespace "Pixie.Editor.Tile.Models", (exports) ->

  class exports.LayerList extends Backbone.Collection
    initialize: ->
      @bind 'activate', (layer) =>
        @activeLayer(layer)

    model: exports.Layer

    activeLayer: (newLayer) ->
      if newLayer?
        @_activeLayer = newLayer

        @trigger "change:activeLayer", @_activeLayer, this

        return this
      else
        return @_activeLayer
