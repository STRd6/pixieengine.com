namespace "Pixie.Editor.Tile.Models", (Models) ->

  class Models.Layer extends Backbone.Model
    defaults:
      name: "Layer"
      visible: true
      zIndex: 0

    initialize: ->
      @objectInstances = new Models.InstanceList

    addObjectInstance: (instance) ->
      @objectInstances.add instance
