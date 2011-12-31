# require ./layer

namespace "Pixie.Editor.Tile.Models", (Models) ->

  class Models.LayerList extends Backbone.Collection
    initialize: ->
      @bind 'activate', (layer) =>
        @activeLayer(layer)

      @bind 'change:zIndex', =>
        @sort()

    comparator: (model) ->
      model.get "zIndex"

    model: Models.Layer
