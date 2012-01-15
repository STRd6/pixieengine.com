namespace "Pixie.Editor.Tile.Models", (Models) ->

  class Models.Layer extends Backbone.Model
    defaults:
      name: "Layer"
      visible: true
      zIndex: 0

    initialize: ->
      @instanceCache = {}
      @objectInstances = new Models.InstanceList

    addObjectInstance: (instance) ->
      @objectInstances.add instance

      key = "#{instance.get 'x'}x#{instance.get 'y'}"
      @instanceCache[key] = instance
      
    instanceAt: (x, y) ->
      key = "#{x}x#{y}"

      return @instanceCache[key]

    removeObjectInstance: (instance) ->
      key = "#{instance.get 'x'}x#{instance.get 'y'}"

      if instance == @instanceCache[key]
        delete @instanceCache[key]

      @objectInstances.remove instance

    toJSON: ->
      name: @get "name"
      instances: @objectInstances.toJSON()
