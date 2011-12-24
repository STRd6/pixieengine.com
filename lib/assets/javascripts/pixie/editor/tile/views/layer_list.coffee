namespace "Pixie.Editor.Tile.Views", (exports) ->
  Models = Pixie.Editor.Tile.Models

  UI = Pixie.UI

  class exports.LayerList extends Backbone.View
    initialize: ->
      # Force jQuery Element
      @el = $(@el)

      @collection.bind 'add', @appendLayer
      @collection.bind "change:activeLayer", (model, collection) =>
        @$('ul li.layer').eq(collection.indexOf(model)).takeClass 'active'

      @el.liveEdit ".name",
        change: (element, value) =>
          cid = element.parent().data("cid")

          @collection.getByCid(cid).set name: value

      # Set up HTML
      @el.append UI.Button
        class: "new"
        text: "New Layer"

      @el.append "<ul />"

      @$("ul").sortable
        axis: "y"
        update: (event, ui) =>
          @$("ul li").each (i, li) =>
            cid = $(li).data("cid")
            debugger unless cid?
            @collection.getByCid(cid).set zIndex: i

      @collection.bind 'reset', @render

      @render()

    render: =>
      @$('ul').empty()

      @collection.each (layer) =>
        @appendLayer layer

      # Hack to display the active layer
      @collection.trigger "change:activeLayer", @collection._activeLayer, @collection

    addLayer: ->
      layer = new Models.Layer

      newIndex = @collection.length + 1

      layer.set
        name: "Layer #{newIndex}"
        zIndex: newIndex

      @collection.add layer

    appendLayer: (layer) =>
      layerView = new exports.Layer
        model: layer

      @$('ul').append layerView.render().el

    events:
      'click button.new': 'addLayer'
