#= require tmpls/pixie/editor/tile/screen

namespace "Pixie.Editor.Tile.Views", (Views) ->
  Models = Pixie.Editor.Tile.Models

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

    localPosition: (event) =>
      {currentTarget} = event

      cursorWidth = @settings.get "tileWidth"
      cursorHeight = @settings.get "tileHeight"

      offset = $(currentTarget).offset()

      x: (event.pageX - offset.left).clamp(0, @settings.pixelWidth() - cursorWidth).snap(cursorWidth)
      y: (event.pageY - offset.top).clamp(0, @settings.pixelHeight() - cursorHeight).snap(cursorHeight)

    adjustCursor: (event) =>
      {x, y} = @localPosition(event)

      @$(".cursor").css
        left: x - 1
        top: y - 1

    addInstance: (event) =>
      {x, y} = @localPosition(event)

      if activeLayer = @settings.get "activeLayer"
        activeEntity = @settings.get "activeEntity"

        activeLayer.addObjectInstance new Models.Instance
          x: x
          y: y
          sourceEntity: activeEntity

    events:
      "mousemove .canvas": "adjustCursor"
      "mousedown .canvas": "addInstance"
