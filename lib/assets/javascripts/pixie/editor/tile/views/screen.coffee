#= require tmpls/pixie/editor/tile/screen

namespace "Pixie.Editor.Tile.Views", (exports) ->
  Models = Pixie.Editor.Tile.Models
  Views = exports

  UI = Pixie.UI

  class Views.Screen extends Backbone.View
    className: "screen"

    initialize: ->
      # Force jQuery Element
      @el = $(@el)

      # Set up HTML
      @el.html $.tmpl("pixie/editor/tile/screen")

      @settings = @options.settings

      @collection.bind 'add', @appendLayer

      @collection.bind 'reset', @render

      @render()

    render: =>
      @$('ul').empty().css
        height: @settings.pixelHeight()
        width: @settings.pixelWidth()

      @collection.each (layer) =>
        @appendLayer layer

    appendLayer: (layer) =>
      layerView = new Views.ScreenLayer
        model: layer
        settings: @settings

      @$("ul.layers").append layerView.render().el
