#= require tmpls/pixie/editor/tile/layer_selection

namespace "Pixie.Editor.Tile.Views", (Views) ->
  Models = Pixie.Editor.Tile.Models

  class Views.LayerSelection extends Backbone.View
    className: 'component layer_selection'

    initialize: ->
      # Force jQuery Element
      @el = $(@el)

      @collection.bind 'add', @appendLayer
      @collection.bind 'reset', @render

      @el.liveEdit ".name",
        change: (element, value) =>
          cid = element.parent().data("cid")

          @collection.getByCid(cid).set name: value

      # Set up HTML
      @el.html $.tmpl("pixie/editor/tile/layer_selection")

      @$("ul").sortable
        axis: "y"
        distance: 10
        update: (event, ui) =>
          @$("ul li").each (i, li) =>
            cid = $(li).data("cid")
            debugger unless cid?
            @collection.getByCid(cid).set zIndex: i

      @options.settings.bind "change:activeLayer", (settings) =>
        if layer = settings.get("activeLayer")
          @$("[data-cid=#{layer.cid}]").takeClass "active"

      @render()

    render: =>
      @$('ul').empty()

      @collection.each (layer) =>
        @appendLayer layer

    addLayer: ->
      layer = new Models.Layer

      newIndex = @collection.length + 1

      layer.set
        name: "Layer #{newIndex}"
        zIndex: newIndex

      @collection.add layer

    appendLayer: (layer) =>
      layerView = new Views.Layer
        model: layer
        settings: @options.settings

      @$('ul').append layerView.render().el

    events:
      'click button.new': 'addLayer'
