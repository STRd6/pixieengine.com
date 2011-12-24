namespace "Pixie.Editor.Tile.Views", (exports) ->
  Models = Pixie.Editor.Tile.Models

  UI = Pixie.UI

  class exports.Screen extends Backbone.View
    initialize: ->
      # Force jQuery Element
      @el = $(@el)

      @collection.bind 'add', @appendLayer

      # @collection.bind "change:activeLayer"
      # TODO Set zIndex of cursor

      @collection.bind 'reset', @render

      @render()

    render: =>

    appendLayer: (layer) =>
      layerView = new exports.Layer
        model: layer

      # @$('.viewport').append layerView.render().el
