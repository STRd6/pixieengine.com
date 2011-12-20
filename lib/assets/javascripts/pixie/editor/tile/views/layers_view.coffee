namespace "Pixie.Editor.Tile.Views", (exports) ->
  Models = Pixie.Editor.Tile.Models

  class exports.LayersView extends Backbone.View
    counter: 0

    initialize: ->
      @collection = new Models.LayerList
      @collection.bind 'add', @appendLayer
      @collection.bind "change:activeLayer", (model, collection) =>
        @$('ul li.layer').eq(collection.indexOf(model)).takeClass 'active'

      @render()

    render: ->
      @el.append '<button>Add List Item</button>'
      @el.append '<ul></ul>'

    addLayer: ->
      @counter += 1

      layer = new Models.Layer

      layer.set
        name: "Layer #{@counter}"

      @collection.add layer

    appendLayer: (layer) =>
      layerView = new exports.Layer
        model: layer

      @$('ul').append layerView.render().el

    events:
      'click button': 'addLayer'
