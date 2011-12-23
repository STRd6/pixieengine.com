namespace "Pixie.Editor.Tile.Views", (exports) ->
  Models = Pixie.Editor.Tile.Models

  UI = Pixie.UI

  class exports.LayersView extends Backbone.View
    initialize: ->
      @collection.bind 'add', @appendLayer
      @collection.bind "change:activeLayer", (model, collection) =>
        @$('ul li.layer').eq(collection.indexOf(model)).takeClass 'active'

      @el.liveEdit(".name")

      @render()

    render: ->
      @el.append UI.Button
        class: "new"
        text: "New Layer"

      @el.append '<ul></ul>'

      @collection.each (layer) =>
        @appendLayer layer

    addLayer: ->
      layer = new Models.Layer

      layer.set
        name: "Layer #{@collection.length + 1}"

      @collection.add layer

    appendLayer: (layer) =>
      layerView = new exports.Layer
        model: layer

      @$('ul').append layerView.render().el

    events:
      'click button.new': 'addLayer'
