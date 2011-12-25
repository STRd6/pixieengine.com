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
      grid = GridGen
        width: @settings.get "tileWidth"
        height: @settings.get "tileHeight"

      @$('.canvas').css
        height: @settings.pixelHeight()
        width: @settings.pixelWidth()
        backgroundImage: grid.backgroundImage()

      @$(".cursor").css
        width: @settings.get("tileWidth") - 1
        height: @settings.get("tileHeight") - 1

      @$(".canvas ul.layers").empty()

      @collection.each (layer) =>
        @appendLayer layer

    appendLayer: (layer) =>
      layerView = new Views.ScreenLayer
        model: layer
        settings: @settings

      @$("ul.layers").append layerView.render().el

    adjustCursor: (event) =>
      {currentTarget} = event

      offset = $(currentTarget).offset()

      left = event.pageX - offset.left
      top = event.pageY - offset.top

      @$(".cursor").css
        top: top.snap(@settings.get "tileHeight")
        left: left.snap(@settings.get "tileWidth")

    events:
      "mousemove .canvas": "adjustCursor"
